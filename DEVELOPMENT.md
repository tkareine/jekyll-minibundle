# Development

Use [Bundler] to install project dependencies. Because we support Jekyll
versions 3 and 4, we have separate [Gemfiles][BundlerGemfile] for
installing dependencies:

* [Gemfile-jekyll3](Gemfile-jekyll3) for Jekyll 3
* [Gemfile-jekyll3](Gemfile-jekyll4) for Jekyll 4

Install dependencies for the selected Gemfile:

``` shell
BUNDLE_GEMFILE=Gemfile-jekyll4 bundle install
```

Use the [Rakefile](Rakefile) to run common tasks. To see the tasks
available:

``` shell
BUNDLE_GEMFILE=Gemfile-jekyll4 bundle exec rake -D
```

Run linter ([Rubocop]) and tests:

``` shell
BUNDLE_GEMFILE=Gemfile-jekyll4 bundle exec rake
```

[BundlerGemfile]: https://bundler.io/v2.0/man/gemfile.5.html
[Bundler]: https://bundler.io/
[Jekyll]: https://jekyllrb.com/
[Rubocop]: https://docs.rubocop.org/en/stable/
