module Jekyll::Minibundle::Test
  module FixtureConfig
    STAMP_SOURCE_PATH = '_tmp/site.css'
    STAMP_DESTINATION_PATH = 'assets/screen.css'
    STAMP_DESTINATION_FINGERPRINT_PATH = 'assets/screen-d57c1404fe726e66d57128a1bd190cbb.css'

    CSS_BUNDLE_SOURCE_DIR = '_assets/styles'
    CSS_BUNDLE_DESTINATION_PATH = 'assets/site'
    CSS_BUNDLE_DESTINATION_FINGERPRINT_PATH = CSS_BUNDLE_DESTINATION_PATH + '-b2e0ecc1c100effc2c7353caad20c327.css'
    
    JS_BUNDLE_SOURCE_DIR = '_assets/scripts'
    JS_BUNDLE_DESTINATION_PATH = 'assets/site'
    JS_BUNDLE_DESTINATION_FINGERPRINT_PATH = JS_BUNDLE_DESTINATION_PATH + '-4782a1f67803038d4f8351051e67deb8.js'
  end
end
