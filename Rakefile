# encoding: UTF-8
require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'rdoc/task'

require 'rake/testtask'

namespace :test do

  desc "Run all tests for the ActiveRecord backend"
  Rake::TestTask.new(:active_record) do |t|
    t.pattern = 'test/**/*_test.rb'
    t.libs = [ "test/dummy_active_record" ]
  end

  desc "Run all tests for the Mongoid backend"
  Rake::TestTask.new(:mongoid) do |t|
    t.pattern = 'test/**/*_test.rb'
    t.libs = [ "test/dummy_mongoid" ]
  end
  desc "Runs all tests"
  task "all"=> [ :active_record, :mongoid ]

  desc "Prepare environment for tests"
  task :prepare do
    Dir.chdir File.expand_path("../test/dummy_active_record", __FILE__) do
      system("rake db:create:all db:migrate db:test:clone")
    end
  end

end

task :default=> 'test:all'

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DjMon'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

