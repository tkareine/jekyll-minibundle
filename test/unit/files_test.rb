require 'support/test_case'
require 'jekyll/minibundle/files'

module Jekyll::Minibundle::Test
  class FilesTest < TestCase
    def test_copy_p
      with_tmp_dir do
        File.write('foo', 'content')
        Files.copy_p('foo', 'bar/zap')
        copied = File.read('bar/zap')
        assert_equal('content', copied)
      end
    end

    def test_read_last_with_non_existing_file_raises_exception
      assert_raises(Errno::ENOENT) { Files.read_last('no-such-file', 4) }
    end

    def test_read_last_with_empty_file_returns_empty
      Tempfile.open('test') do |file|
        file.close

        assert_equal('', Files.read_last(file.path, 4))
      end
    end

    def test_read_last_with_file_bigger_than_max_size_returns_last_bytes
      Tempfile.open('test') do |file|
        file.write("1\n2\n3\n4")
        file.close

        assert_equal("\n3\n4", Files.read_last(file.path, 4))
      end
    end

    def test_read_last_with_file_smaller_than_max_size_returns_all_contents
      Tempfile.open('test') do |file|
        file.write("1\n2")
        file.close

        assert_equal("1\n2", Files.read_last(file.path, 100))
      end
    end

    def test_read_last_with_max_size_zero_or_negative_returns_empty
      Tempfile.open('test') do |file|
        file.write("1\n2")
        file.close

        assert_equal('', Files.read_last(file.path, 0))
        assert_equal('', Files.read_last(file.path, -1))
      end
    end

    def test_strip_dot_slash_from_path_start
      assert_equal('path', Files.strip_dot_slash_from_path_start('./path'))
    end
  end
end
