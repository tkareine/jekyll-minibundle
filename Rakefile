task :test do
  libs = %w{lib test}.join(':')
  tests = %w{integration/compile_test}.join(' ')
  sh %{ruby -I#{libs} -e 'ARGV.each { |f| require f }' #{tests}}
end
