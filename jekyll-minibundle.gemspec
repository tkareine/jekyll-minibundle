# frozen_string_literal: true

require_relative 'lib/jekyll/minibundle/version'

Gem::Specification.new do |s|
  s.name     = 'jekyll-minibundle'
  s.version  = Jekyll::Minibundle::VERSION
  s.summary  = 'A minimalistic asset bundling plugin for Jekyll'
  s.authors  = ['Tuomas Kareinen']
  s.email    = 'tkareine@gmail.com'
  s.homepage = 'https://github.com/tkareine/jekyll-minibundle'
  s.license  = 'MIT'

  s.description = <<~TEXT
    A straightforward asset bundling plugin for Jekyll, utilizing external
    minification tool of your choice. It provides asset concatenation for
    bundling and asset fingerprinting with MD5 digest for cache busting.
    There are no other runtime dependencies besides the minification tool
    (not even other gems).
  TEXT

  s.metadata = {
    'rubygems_mfa_required' => 'true'
  }

  s.files = %w[
    CHANGELOG.md
    LICENSE.txt
    README.md
    Rakefile
    jekyll-minibundle.gemspec
  ] + `git ls-files -- lib`.split("\n")

  s.required_ruby_version = '>= 2.7.0'

  s.rdoc_options << '--line-numbers' << '--title' << s.name << '--exclude' << 'test'
end
