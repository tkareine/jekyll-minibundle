require 'fileutils'
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

def run_jekyll_in_fixture_site(command)
  Dir.chdir('test/fixture/site')
  FileUtils.rm_rf('_site')
  sh get_minibundle_env, "jekyll #{command}"
end

namespace :gem do
  gem_name = 'jekyll-minibundle'

  CLEAN.include "#{gem_name}-*.gem"

  desc 'Package the software as a gem'
  task :build => :test do
    sh %{gem build #{gem_name}.gemspec}
  end

  desc 'Install the software as a gem'
  task :install do
    sh %{gem install #{gem_name}-#{Jekyll::Minibundle::VERSION}.gem}
  end

  desc 'Uninstall the gem'
  task :uninstall => :clean do
    sh %{gem uninstall #{gem_name}}
  end
end

desc 'Run tests; envars: tests=<test_path> to select a particular suite, debug=1 to require Pry and PP'
task :test do
  glob = ENV['tests'] || 'test/{unit,integration}/*_test.rb'
  files = Dir[glob].
    map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }.
    shelljoin
  opts = ENV['debug'] ? '-rpp -rpry' : ''
  eval = %{-e 'ARGV.each { |f| require f }'}
  cmd = "ruby #{opts} #{eval} #{files}"
  env = get_minibundle_env('RUBYLIB' => 'lib:test')
  sh env, cmd
end

namespace :fixture do
  CLEAN.include 'test/fixture/site/_site'

  desc 'Generate fixture site'
  task :build do
    run_jekyll_in_fixture_site('build')
  end

  desc 'Generate fixture site in watch mode'
  task :watch do
    run_jekyll_in_fixture_site('build --watch')
  end
end

task :default => :test
