require 'digest/md5'

module Jekyll::Minibundle
  module AssetStamp
    def self.for(path)
      Digest::MD5.hexdigest File.read(path)
    end
  end
end
