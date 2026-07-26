# frozen_string_literal: true

require 'bundler/gem_helper'
require 'fileutils'
require 'rake/clean'
require 'shellwords'
require 'rubocop/rake_task'

require_relative 'lib/jekyll/minibundle/version'

def run_jekyll_in_fixture_site(command)
  Dir.chdir('test/fixture/site')
  FileUtils.rm_rf('_site')

  minifier_cmd = File.expand_path('test/fixture/site/_bin/remove_comments', File.dirname(__FILE__))
  env = {
    'JEKYLL_MINIBUNDLE_CMD_JS'  => minifier_cmd,
    'JEKYLL_MINIBUNDLE_CMD_CSS' => minifier_cmd,
    'RUBYLIB'                   => File.expand_path('lib', File.dirname(__FILE__))
  }
  jekyll_cmd = "jekyll #{command}"

  sh env, jekyll_cmd
end

desc <<~TEXT
  Run benchmarks. Supported options from environment variables:

  BM=<benchmark_suite_path>
TEXT
task :benchmark do
  run_single_bm = ENV.key?('BM')

  bm_sources =
    if run_single_bm
      [ENV.fetch('BM')]
    else
      Dir['benchmark/*_bm.rb']
    end

  bm_sources.each do |bm_source|
    sh "ruby -I lib #{bm_source}"
  end
end

desc <<~TEXT
  Run tests. Supported options from environment variables:

  TEST=<test_suite_path>
  NAME=<test_name_pattern>
  DEBUG=1                     Require Pry, PP, enable warnings
  SEED=n                      Set the random seed
  TEST_OPTS='-v'              Enable other minitest options
TEXT
task :test do
  run_selected_or_all =
    if ENV.key?('TEST')
      test_file = ENV['TEST']
      minitest_opts = "#{"-n #{ENV['NAME']} " if ENV.key?('NAME')}#{ENV.fetch('TEST_OPTS', '')}"
      "#{test_file} #{minitest_opts}"
    else
      eval = "-e 'ARGV.each { |f| require \"#{Dir.pwd}/test/\#{f}\" }'"
      requirable_files =
        Dir['test/{unit,integration}/*_test.rb']
        .map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }
        .shelljoin
      "#{eval} #{requirable_files}"
    end

  ruby_opts = "-I lib#{' -w -rpp -rpry' if ENV['DEBUG']}"

  puts "Jekyll version: #{Gem::Specification.find_by_name('jekyll').version}"
  sh "ruby #{ruby_opts} #{run_selected_or_all}"
end

namespace :fixture do
  CLOBBER.include 'test/fixture/site/_site', 'test/fixture/site/.jekyll-cache'

  desc 'Generate fixture site (tests use it, this task allows manual inspection)'
  task :build do
    run_jekyll_in_fixture_site('build')
  end

  desc 'Generate fixture site in watch mode'
  task :watch do
    run_jekyll_in_fixture_site('build --watch')
  end
end

Bundler::GemHelper.install_tasks

RuboCop::RakeTask.new

task default: %i[rubocop test]
