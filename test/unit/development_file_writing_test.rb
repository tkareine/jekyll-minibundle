require 'support/test_case'
require 'support/fixture_config'
require 'jekyll/minibundle/development_file'

module Jekyll::Minibundle::Test
  class DevelopmentFileWritingTest < TestCase
    include FixtureConfig

    def test_modify_property_determines_if_write_would_succeed
      with_fake_site do |site|
        dev_file = make_development_file(site)
        source = source_path(STAMP_SOURCE_PATH)

        assert dev_file.modified?
        assert write_file(dev_file)

        ensure_file_mtime_changes do
          FileUtils.touch(source)
        end

        assert dev_file.modified?
        assert write_file(dev_file)

        refute dev_file.modified?
        refute write_file(dev_file)
      end
    end

    private

    def make_development_file(site)
      DevelopmentFile.new(site, STAMP_SOURCE_PATH, STAMP_DESTINATION_PATH)
    end

    def write_file(file)
      file.write(File.join(Dir.pwd, '_site'))
    end
  end
end
