require 'fileutils'
require 'rake/clean'
require 'shellwords'
require 'rubocop/rake_task'

require_relative 'lib/jekyll/minibundle/version'

def run_jekyll_in_fixture_site(command)
  Dir.chdir('test/fixture/site')
  FileUtils.rm_rf('_site')

  minifier_cmd = File.expand_path(File.join(File.dirname(__FILE__), 'test/fixture/site/_bin/remove_comments'))
  env = {
    'JEKYLL_MINIBUNDLE_CMD_JS'  => minifier_cmd,
    'JEKYLL_MINIBUNDLE_CMD_CSS' => minifier_cmd,
    'RUBYLIB'                   => File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
  }
  jekyll_cmd = "jekyll #{command}"

  sh env, jekyll_cmd
end

desc 'Run benchmarks; BM=<benchmark_suite_path>'
task :benchmark do
  run_single_bm = ENV.key?('BM')

  bm_sources =
    if run_single_bm
      [ENV['BM']]
    else
      Dir['benchmark/*_bm.rb']
    end

  bm_sources.each do |bm_source|
    sh "ruby -I lib #{bm_source}"
  end
end

namespace :gem do
  gem_name = 'jekyll-minibundle'

  CLEAN.include "#{gem_name}-*.gem"

  desc 'Package the software as a gem'
  task build: :default do
    sh "gem build #{gem_name}.gemspec"
  end

  desc 'Install the software as a gem'
  task :install do
    sh "gem install #{gem_name}-#{Jekyll::Minibundle::VERSION}.gem"
  end

  desc 'Uninstall the gem'
  task uninstall: :clean do
    sh "gem uninstall #{gem_name}"
  end
end

desc 'Run tests; TEST=<test_suite_path>, NAME=<test_name_pattern>, DEBUG=1 to require Pry, PP, enable warnings'
task :test do
  run_single_test = ENV.key?('TEST')

  run_selected_or_all =
    if run_single_test
      rb_file = ENV['TEST']
      name_opt = ENV.key?('NAME') ? " -n #{ENV['NAME']}" : ''
      "#{rb_file}#{name_opt}"
    else
      requirable_files =
        Dir['test/{unit,integration}/*_test.rb']
        .map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }
        .shelljoin
      eval = "-e 'ARGV.each { |f| require f }'"
      "#{eval} #{requirable_files}"
    end

  extra_opts = ENV['DEBUG'] ? '-w -rpp -rpry ' : ''

  sh "ruby -I lib:test #{extra_opts}#{run_selected_or_all}"
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

RuboCop::RakeTask.new

task default: [:test, :rubocop]
