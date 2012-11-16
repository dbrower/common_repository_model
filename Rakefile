require "bundler/gem_tasks"

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.verbose = true
end

task :default => :test

# These two items are included for internal testing purposes.
import(
  File.expand_path(
    'lib/tasks/common_repository_model.tasks', File.dirname(__FILE__)
  )
)
task :environment do
  require 'active_fedora'
  ActiveFedora.init(
    fedora_config_path: File.join(File.dirname(__FILE__),"spec/config/fedora.yml"),
    solr_config_path: File.join(File.dirname(__FILE__),"spec/config/solr.yml"),
    environment: :test
  )
end
