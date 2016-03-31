if defined?(Jekyll::VERSION) && Jekyll::VERSION < '3'
  raise 'Minibundle plugin requires Jekyll version 3 or above'
end

require 'jekyll/minibundle/version'
require 'jekyll/minibundle/mini_bundle_block'
require 'jekyll/minibundle/mini_stamp_tag'
