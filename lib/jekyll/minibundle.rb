if defined?(Jekyll::VERSION) &&
   defined?(Gem::Version) &&
   (Gem::Version.create(Jekyll::VERSION) < Gem::Version.create('3.0.0'))
  raise 'Minibundle plugin requires Jekyll version >= 3.0.0'
end

require 'jekyll/minibundle/version'
require 'jekyll/minibundle/mini_bundle_block'
require 'jekyll/minibundle/mini_stamp_tag'
