require 'digest/md5'

module Jekyll::Minibundle
  module AssetStamp
    def self.from_file(path)
      Digest::MD5.file(path).hexdigest
    end
  end
end
