require File.expand_path(File.join(File.dirname(__FILE__), 'lib/jekyll/minibundle/version'))

Gem::Specification.new do |s|
  s.name        = 'jekyll-minibundle'
  s.version     = Jekyll::Minibundle::VERSION
  s.summary     = 'Straightforward asset bundling plugin for Jekyll'
  s.authors     = ['Tuomas Kareinen']
  s.email       = 'tkareine@gmail.com'
  s.homepage    = 'https://github.com/tkareine/jekyll-minibundle'
  s.licenses    = %w{MIT}

  s.description = <<-END
Provides 'minibundle' block for bundling multiple assets, 'ministamp'
tag for stamping a single asset.

No other dependencies than the asset bundler of your choice.
  END

  s.files = %w{
    History.md
    Rakefile
    Readme.md
    lib/jekyll/minibundle.rb
    lib/jekyll/minibundle/asset_bundle.rb
    lib/jekyll/minibundle/asset_file_support.rb
    lib/jekyll/minibundle/asset_stamp.rb
    lib/jekyll/minibundle/bundle_file.rb
    lib/jekyll/minibundle/bundle_markup.rb
    lib/jekyll/minibundle/mini_bundle_block.rb
    lib/jekyll/minibundle/mini_stamp_tag.rb
    lib/jekyll/minibundle/stamp_file.rb
  }

  s.test_files = %w{
    test/fixture/site/_assets/scripts/app.js
    test/fixture/site/_assets/scripts/dependency.js
    test/fixture/site/_assets/styles/common.css
    test/fixture/site/_assets/styles/reset.css
    test/fixture/site/_bin/remove_comments
    test/fixture/site/_plugins/minibundle.rb
    test/fixture/site/_tmp/site.css
    test/fixture/site/index.html
    test/integration/minibundle_test.rb
    test/integration/ministamp_test.rb
    test/support/test_case.rb
  }

  s.add_development_dependency 'jekyll',   '~> 0.11.2'
  s.add_development_dependency 'minitest', '~> 4.3.3'
  s.add_development_dependency 'nokogiri', '~> 1.5.5'

  s.rdoc_options << '--line-numbers' << '--title' << s.name << '--exclude' << 'test'
end
