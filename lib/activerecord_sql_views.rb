require 'valuable'

require 'activerecord_sql_views/version'
require 'activerecord_sql_views/active_record/base'
require 'activerecord_sql_views/active_record/db_default'
require 'activerecord_sql_views/active_record/schema'
require 'activerecord_sql_views/active_record/schema_dumper'
require 'activerecord_sql_views/active_record/connection_adapters/abstract_adapter'
require 'activerecord_sql_views/railtie' if defined?(Rails::Railtie)

module ActiveRecordSqlViews
  module ActiveRecord

    module ConnectionAdapters
      autoload :PostgresqlAdapter, 'activerecord_sql_views/active_record/connection_adapters/postgresql_adapter'
      autoload :PostgreSQLColumn, 'activerecord_sql_views/active_record/connection_adapters/postgresql_adapter'
      autoload :Sqlite3Adapter, 'activerecord_sql_views/active_record/connection_adapters/sqlite3_adapter'
    end
  end

  # This global configuation options for ActiveRecordSqlViews.
  # Set them in +config/initializers/activerecord_sql_views.rb+ using:
  #
  #    ActiveRecordSqlViews.setup do |config|
  #       ...
  #    end
  #
  # The options are grouped into subsets based on area of functionality.
  # See Config::ForeignKeys
  #
  class Config < Valuable

    # This set of configuration options control ActiveRecordSqlViews's foreign key
    # constraint behavior.  Set them in
    # +config/initializers/activerecord_sql_views.rb+ using:
    #
    #    ActiveRecordSqlViews.setup do |config|
    #       config.foreign_keys.auto_create = ...
    #    end
    #
    class ForeignKeys < Valuable
      ##
      # :attr_accessor: auto_create
      #
      # Whether to automatically create foreign key constraints for columns
      # suffixed with +_id+.  Boolean, default is +true+.
      has_value :auto_create, :klass => :boolean, :default => true

      ##
      # :attr_accessor: auto_index
      #
      # Whether to automatically create indexes when creating foreign key constraints for columns.
      # Boolean, default is +true+.
      has_value :auto_index, :klass => :boolean, :default => true

      ##
      # :attr_accessor: on_update
      #
      # The default value for +:on_update+ when creating foreign key
      # constraints for columns.  Valid values are as described in
      # ForeignKeyDefinition, or +nil+ to let the database connection use
      # its own default.  Default is +nil+.
      has_value :on_update

      ##
      # :attr_accessor: on_delete
      #
      # The default value for +:on_delete+ when creating foreign key
      # constraints for columns.  Valid values are as described in
      # ForeignKeyDefinition, or +nil+ to let the database connection use
      # its own default.  Default is +nil+.
      has_value :on_delete
    end
    has_value :foreign_keys, :klass => ForeignKeys, :default => ForeignKeys.new

    def dup #:nodoc:
      self.class.new(Hash[attributes.collect{ |key, val| [key, Valuable === val ?  val.class.new(val.attributes) : val] }])
    end

    def update_attributes(opts)#:nodoc:
      opts = opts.dup
      opts.keys.each { |key| self.send(key).update_attributes(opts.delete(key)) if self.class.attributes.include? key and Hash === opts[key] }
      super(opts)
      self
    end

    def merge(opts)#:nodoc:
      dup.update_attributes(opts)
    end

  end

  # Returns the global configuration, i.e., the singleton instance of Config
  def self.config
    @config ||= Config.new
  end

  # Initialization block is passed a global Config instance that can be
  # used to configure ActiveRecordSqlViews behavior.  E.g., if you want to disable
  # automation creation of foreign key constraints for columns name *_id,
  # put the following in config/initializers/activerecord_sql_views.rb :
  #
  #    ActiveRecordSqlViews.setup do |config|
  #       config.foreign_keys.auto_create = false
  #    end
  #
  def self.setup # :yields: config
    yield config
  end

  def self.insert_connection_adapters #:nodoc:
    return if @inserted_connection_adapters
    @inserted_connection_adapters = true
    ::ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:include, ActiveRecordSqlViews::ActiveRecord::ConnectionAdapters::AbstractAdapter)
  end

  def self.insert #:nodoc:
    return if @inserted
    @inserted = true
    insert_connection_adapters
    ::ActiveRecord::Base.send(:include, ActiveRecordSqlViews::ActiveRecord::Base)
    ::ActiveRecord::Schema.send(:include, ActiveRecordSqlViews::ActiveRecord::Schema)
    ::ActiveRecord::SchemaDumper.send(:include, ActiveRecordSqlViews::ActiveRecord::SchemaDumper)
    ::ActiveRecord.const_set(:DB_DEFAULT, ActiveRecordSqlViews::ActiveRecord::DB_DEFAULT)
  end

end

ActiveRecordSqlViews.insert unless defined? Rails::Railtie
