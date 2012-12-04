require 'support/test_case'

module Jekyll::Minibundle::Test
  class GenerationTest < TestCase
    def setup
      options = {
        'source'      => 'test/fixture/site',
        'destination' => 'test/fixture/site/_site'
      }
      Jekyll::Site.new(Jekyll.configuration(options)).process
    end

    def test_generate

    end
  end
end
