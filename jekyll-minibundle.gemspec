require_relative 'lib/jekyll/minibundle/version'

Gem::Specification.new do |s|
  s.name     = 'jekyll-minibundle'
  s.version  = Jekyll::Minibundle::VERSION
  s.summary  = 'A minimalistic asset bundling plugin for Jekyll'
  s.authors  = ['Tuomas Kareinen']
  s.email    = 'tkareine@gmail.com'
  s.homepage = 'https://github.com/tkareine/jekyll-minibundle'
  s.license  = 'MIT'

  s.description = <<-END
A straightforward asset bundling plugin for Jekyll, utilizing external
minification tool of your choice. It provides asset concatenation for
bundling and asset fingerprinting with MD5 digest for cache busting.
There are no other runtime dependencies besides the minification tool
(not even other gems).
  END

  s.files = %w{
    CHANGELOG.md
    LICENSE.txt
    README.md
    Rakefile
    jekyll-minibundle.gemspec
  } + `git ls-files -- lib`.split("\n")

  s.test_files = `git ls-files -- test`.split("\n")

  s.add_development_dependency 'benchmark-ips', '~> 2.7'
  s.add_development_dependency 'jekyll',        '~> 3.0'
  s.add_development_dependency 'minitest',      '~> 5.8'
  s.add_development_dependency 'nokogiri',      '~> 1.6'
  s.add_development_dependency 'pry',           '~> 0.10'
  s.add_development_dependency 'rake',          '~> 12.0'
  s.add_development_dependency 'rubocop',       '~> 0.47.0'

  s.required_ruby_version = '>= 2.0.0'

  s.rdoc_options << '--line-numbers' << '--title' << s.name << '--exclude' << 'test'
end
