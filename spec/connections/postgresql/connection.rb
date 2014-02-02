print "Using PostgreSQL\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new(File.open("postgresql.log", "w"))

ActiveRecord::Base.configurations = {
  'activerecord_sql_views' => {
    :adapter => 'postgresql',
    :username => ENV['POSTGRES_DB_USER'],
    :database => 'activerecord_sql_views_test',
    :min_messages => 'warning'
  }

}

ActiveRecord::Base.establish_connection 'activerecord_sql_views'
