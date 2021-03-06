require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Item < ActiveRecord::Base
end

class AOnes < ActiveRecord::Base
end

class ABOnes < ActiveRecord::Base
end

describe ActiveRecord do

  let(:schema) { ActiveRecord::Schema }

  let(:migration) { ActiveRecord::Migration }

  let(:connection) { ActiveRecord::Base.connection }

  let (:dump) {
    StringIO.open { |stream|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
      stream.string
    }
  }

  context "views" do

    around (:each) do |example|
      define_schema_and_data
      example.run
      drop_definitions
    end

    it "should query correctly" do
      AOnes.all.collect(&:s).should == %W[one_one one_two]
      ABOnes.all.collect(&:s).should == %W[one_one]
    end

    it "should instrospect" do
      connection.views.sort.should == %W[a_ones ab_ones]
      connection.view_definition('a_ones').should match(%r{^SELECT .*b.*,.*s.* FROM .*items.* WHERE .*a.* = 1}i)
      connection.view_definition('ab_ones').should match(%r{^SELECT .*s.* FROM .*a_ones.* WHERE .*b.* = 1}i)
    end

    it "should not be listed as a table" do
      connection.tables.should_not include('a_ones')
      connection.tables.should_not include('ab_ones')
    end


    it "should be included in schema dump" do
      dump.should match(%r{create_view "a_ones", "SELECT .*b.*,.*s.* FROM .*items.* WHERE .*a.* = 1.*, :force => true}i)
      dump.should match(%r{create_view "ab_ones", "SELECT .*s.* FROM .*a_ones.* WHERE .*b.* = 1.*, :force => true}i)
    end

    it "should be included in schema dump in dependency order" do
      dump.should match(%r{create_table "items".*create_view "a_ones".*create_view "ab_ones"}m) 
    end

    it "dump should not reference current database" do
      # why check this?  mysql default to providing the view definition
      # with tables explicitly scoped to the current database, which
      # resulted in the dump being bound to the current database.  this
      # caused trouble for rails, in which creates the schema dump file
      # when in the (say) development database, but then uses it to
      # initialize the test database when testing.  this meant that the
      # test database had views into the development database.
      db = connection.respond_to?(:current_database)? connection.current_database : ActiveRecord::Base.configurations['activerecord_sql_views'][:database]
      dump.should_not match(%r{#{connection.quote_table_name(db)}[.]})
    end

    context "duplicate view creation" do
      around(:each) do |example|
        migration.suppress_messages do
          begin
            migration.create_view('dupe_me', 'SELECT * FROM items WHERE (a=1)')
            example.run
          ensure
            migration.drop_view('dupe_me')
          end
        end
      end


      it "should raise an error by default" do
        expect {migration.create_view('dupe_me', 'SELECT * FROM items WHERE (a=2)')}.to raise_error ActiveRecord::StatementInvalid
      end

      it "should override existing definition if :force true" do
        migration.create_view('dupe_me', 'SELECT * FROM items WHERE (a=2)', :force => true)
        connection.view_definition('dupe_me').should =~ %r{WHERE .*a.*=.*2}i
      end
    end
  end

  protected

  def define_schema_and_data
    migration.suppress_messages do
      connection.views.each do |view| connection.drop_view view end
      connection.tables.each do |table| connection.drop_table table, cascade: true end

      schema.define do

        create_table :items, :force => true do |t|
          t.integer :a
          t.integer :b
          t.string  :s
        end

        create_view :a_ones, Item.select('b, s').where(:a => 1)
        create_view :ab_ones, "select s from a_ones where b = 1"
      end
    end
    connection.execute "insert into items (a, b, s) values (1, 1, 'one_one')"
    connection.execute "insert into items (a, b, s) values (1, 2, 'one_two')"
    connection.execute "insert into items (a, b, s) values (2, 1, 'two_one')"
    connection.execute "insert into items (a, b, s) values (2, 2, 'two_two')"

  end

  def drop_definitions
    migration.suppress_messages do
      schema.define do
        drop_view "ab_ones"
        drop_view "a_ones"
        drop_table "items"
      end
    end
  end

  def dump
    StringIO.open { |stream|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
      stream.string
    }
  end

end
