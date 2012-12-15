require 'rake/clean'
require 'shellwords'

require_relative 'lib/jekyll/minibundle/version'

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
  test_dir = 'test'
  test_glob = '**/*_test.rb'
  includes = ['lib', test_dir].join(':')
  tests = Dir["#{test_dir}/#{test_glob}"].
    map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }.
    shelljoin
  test_cmd = %{bundle exec ruby -I#{includes} -e 'ARGV.each { |f| require f }' #{tests}}
  bundle_cmd = File.expand_path(File.join(File.dirname(__FILE__), test_dir, 'fixture/site/_bin/remove_comments'))
  env = {
    'JEKYLL_MINIBUNDLE_CMD_JS' => bundle_cmd,
    'JEKYLL_MINIBUNDLE_CMD_CSS' => bundle_cmd
  }
  sh(env, test_cmd)
end

CLEAN.include 'test/fixture/site/_site'

task :default => :test
