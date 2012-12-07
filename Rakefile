require 'rake/clean'
require 'shellwords'

desc 'Run tests'
task :test do
  test_dir = 'test'
  test_glob = 'integration/**/*_test.rb'
  includes = ['lib', test_dir].join(':')
  tests = Dir["#{test_dir}/#{test_glob}"].
    map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }.
    shelljoin
  test_cmd = %{bundle exec ruby -I#{includes} -e 'ARGV.each { |f| require f }' #{tests}}
  bundle_cmd = File.join(File.dirname(__FILE__), test_dir, 'fixture/site/_bin/remove_comments')
  env = {
    'JEKYLL_MINIBUNDLE_CMD_JS' => bundle_cmd,
    'JEKYLL_MINIBUNDLE_CMD_CSS' => bundle_cmd
  }
  sh(env, test_cmd)
end

CLEAN.include 'test/fixture/site/_site'

task :default => :test
