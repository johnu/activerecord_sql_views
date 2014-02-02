print "Using SQLite3\n"
require 'logger'

ActiveRecord::Base.logger = Logger.new(File.open("sqlite3.log", "w"))

ActiveRecord::Base.configurations = {
  'activerecord_sql_views' => {
    :adapter => 'sqlite3',
    :database => File.expand_path('activerecord_sql_views.sqlite3', File.dirname(__FILE__)),
  }

}

ActiveRecord::Base.establish_connection 'activerecord_sql_views'
ActiveRecord::Base.connection.execute "PRAGMA synchronous = OFF"
