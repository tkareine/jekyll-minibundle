module Jekyll::Minibundle
  module Files
    def self.read_last(path, max_size)
      File.open(path, 'rb') do |file|
        return '' if max_size < 1

        file_size = file.stat.size

        if file_size < max_size
          file.read(file_size)
        else
          file.seek(file_size - max_size, ::IO::SEEK_SET)
          file.read(max_size)
        end
      end
    end
  end
end
