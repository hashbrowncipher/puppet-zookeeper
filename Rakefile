require 'bundler'
Bundler.require(:rake)

require 'puppet-lint/tasks/puppet-lint'
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'rake/dsl_definition'
require 'rake/hooks'

PuppetLint.configuration.ignore_paths = ["spec/fixtures/modules/cron/manifests/*.pp", "vendor/**/*"]
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
PuppetLint.configuration.send("disable_80chars")

# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge downloads,...
task :librarian_spec_prep do
  sh "librarian-puppet install --path=spec/fixtures/modules/"
end
task :spec_prep => :librarian_spec_prep
task :default => [:spec, :lint]
