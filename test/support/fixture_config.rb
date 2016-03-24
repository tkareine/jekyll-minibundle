module Jekyll::Minibundle::Test
  module FixtureConfig
    STAMP_SOURCE_PATH = '_tmp/site.css'.freeze
    STAMP_DESTINATION_PATH = 'assets/screen.css'.freeze
    STAMP_FINGERPRINT = 'd57c1404fe726e66d57128a1bd190cbb'.freeze
    STAMP_DESTINATION_FINGERPRINT_PATH = "assets/screen-#{STAMP_FINGERPRINT}.css".freeze

    CSS_BUNDLE_SOURCE_DIR = '_assets/styles'.freeze
    CSS_BUNDLE_DESTINATION_PATH = 'assets/site'.freeze
    CSS_BUNDLE_FINGERPRINT = 'b2e0ecc1c100effc2c7353caad20c327'.freeze
    CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH = "#{CSS_BUNDLE_DESTINATION_PATH}-#{CSS_BUNDLE_FINGERPRINT}.css".freeze

    JS_BUNDLE_SOURCE_DIR = '_assets/scripts'.freeze
    JS_BUNDLE_DESTINATION_PATH = 'assets/site'.freeze
    JS_BUNDLE_FINGERPRINT = '4782a1f67803038d4f8351051e67deb8'.freeze
    JS_BUNDLE_DESTINATION_FINGERPRINT_PATH = "#{JS_BUNDLE_DESTINATION_PATH}-#{JS_BUNDLE_FINGERPRINT}.js".freeze
  end
end
