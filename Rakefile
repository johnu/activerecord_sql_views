require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :spec

desc 'Run test for adapter whose name is suffix of current Gemfile'
task :spec do
    gemfile = ENV['BUNDLE_GEMFILE']
    fail "BUNDLE_GEMFILE environment variable not set" unless gemfile
    adapter = File.extname(gemfile).sub(/^[.]/, '')
    fail "BUNDLE_GEMFILE filename does not end with .db adapter name" if adapter.empty?
    Rake::Task["#{adapter}:spec"].invoke
end

# work around a bug in rake 10.0.3 with ruby 1.9.2
unless RUBY_VERSION == "1.9.2"
    require 'rdoc/task'
    Rake::RDocTask.new do |rdoc|
    require File.dirname(__FILE__) + '/lib/activerecord_sql_views/version'

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "activerecord_sql_views #{ActiveRecordSqlViews::VERSION}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
    end
end

require 'rspec/core/rake_task'
%w[postgresql sqlite3].each do |adapter|
  namespace adapter do
    RSpec::Core::RakeTask.new(:spec) do |spec|
      spec.rspec_opts = "-Ispec/connections/#{adapter}"
      spec.fail_on_error = true
    end
  end
end

DATABASES = %w[ar_sql_views_test]
[ 
  { namespace: :postgresql, uservar: 'POSTGRES_DB_USER', defaultuser: 'postgres', create: "createdb -U '%{user}' %{dbname}", drop: "dropdb -U '%{user}' %{dbname}" }
].each do |db|
  namespace db[:namespace] do
    user = ENV.fetch db[:uservar], db[:defaultuser]
    task :create_databases do
      DATABASES.each do |dbname|
        system(db[:create] % {user: user, dbname: dbname})
      end
    end
    task :drop_databases do
      DATABASES.each do |dbname|
        system(db[:drop] % {user: user, dbname: dbname})
      end
    end
  end
end

desc 'Run postgresql and sqlite3 tests'
task :specs do 
  invoke_multiple(%w[postgresql sqlite3], "spec")
end

desc 'Create test databases'
task :create_databases do
  invoke_multiple(%w[postgresql], "create_databases")
end

desc 'Drop test databases'
task :drop_databases do
  invoke_multiple(%w[postgresql], "drop_databases")
end

def invoke_multiple(namespaces, task)
  failed = namespaces.reject { |adapter|
    begin
      Rake::Task["#{adapter}:#{task}"].invoke
      true
    rescue => e
      warn "\n#{e}\n"
      false
    end
  }
  fail "Failure in: #{failed.join(', ')}" if failed.any?
end
