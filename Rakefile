require 'rake/clean'
require 'shellwords'

require_relative 'lib/jekyll/minibundle/version'

def get_minibundle_env(overrides = {})
  bundle_cmd = File.expand_path(File.join(File.dirname(__FILE__), 'test/fixture/site/_bin/remove_comments'))
  {
    'JEKYLL_MINIBUNDLE_CMD_JS'  => bundle_cmd,
    'JEKYLL_MINIBUNDLE_CMD_CSS' => bundle_cmd,
    'RUBYLIB'                   => File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
  }.merge(overrides)
end

namespace :gem do
  gem_name = 'jekyll-minibundle'

  CLEAN.include "#{gem_name}-*.gem"

  desc 'Package the software as a gem'
  task :build => :test do
    sh %{gem build #{gem_name}.gemspec}
  end

  desc 'Install the software as a gem'
  task :install => :build do
    sh %{gem install #{gem_name}-#{Jekyll::Minibundle::VERSION}}
  end

  desc 'Uninstall the gem'
  task :uninstall => :clean do
    sh %{gem uninstall #{gem_name}}
  end
end

desc 'Run tests'
task :test do
  tests = Dir['test/**/*_test.rb'].
    map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }.
    shelljoin
  test_cmd = %{ruby -e 'ARGV.each { |f| require f }' #{tests}}
  sh(get_minibundle_env('RUBYLIB' => 'lib:test'), test_cmd)
end

desc 'Generate fixture site for debugging'
task :debug do
  Dir.chdir 'test/fixture/site'
  sh(get_minibundle_env, 'jekyll')
end

CLEAN.include 'test/fixture/site/_site'

task :default => :test
