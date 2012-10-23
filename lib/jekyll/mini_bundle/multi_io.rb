module Jekyll::MiniBundle
  class MultiIO
    def initialize(files)
      @current_file = files.first
      @rest_files = files[1..-1]
    end

    def read(length)
      file_read = @current_file.read(length)
      
    end
  end
end
