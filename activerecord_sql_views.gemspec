# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "activerecord_sql_views/version"

Gem::Specification.new do |s|
  s.name        = "activerecord_sql_views"
  s.version     = ActiveRecordSqlViews::VERSION
  s.platform    = Gem::Platform::RUBY
  s.required_ruby_version = ">= 1.9.2"
  s.authors     = ["John Underwood"]
  s.email       = ["kirxco@gmail.com"]
  s.homepage    = "https://github.com/kircxo/activerecord_sql_views"
  s.summary     = "Enhances ActiveRecord schema mechanism for views."
  s.description = "ActiveRecordSqlViews is an ActiveRecord extension that provides capabilities for schema definition for views."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("rails", ">= 3.2")
  s.add_dependency("valuable")

  s.add_development_dependency("rake")
  s.add_development_dependency("rspec")
  s.add_development_dependency("simplecov")
  s.add_development_dependency("simplecov-gem-adapter")
end

