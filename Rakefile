require 'rake/clean'
require 'shellwords'

desc 'Run tests'
task :test do
  uglifyjs_cmd = File.join(File.dirname(__FILE__), '/node_modules/.bin/uglifyjs') + ' --'
  test_dir = 'test'
  test_glob = 'integration/**/*_test.rb'
  includes = ['lib', test_dir].join(':')
  tests = Dir["#{test_dir}/#{test_glob}"].
    map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }.
    shelljoin
  sh({'JEKYLL_MINIBUNDLE_CMD_JS' => uglifyjs_cmd }, %{bundle exec ruby -I#{includes} -e 'ARGV.each { |f| require f }' #{tests}})
end

CLEAN.include 'test/fixture/site/_site'

task :default => :test
