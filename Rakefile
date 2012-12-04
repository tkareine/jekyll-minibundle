require 'shellwords'

desc 'Run tests'
task :test do
  test_dir = 'test'
  test_glob = 'integration/**/*_test.rb'
  includes = ['lib', test_dir].join(':')
  tests = Dir["#{test_dir}/#{test_glob}"].
    map { |file| %r{^test/(.+)\.rb$}.match(file)[1] }.
    shelljoin
  sh %{ruby -I#{includes} -e 'ARGV.each { |f| require f }' #{tests}}
end
