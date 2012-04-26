require 'fileutils'
require 'base64'

class FileBasedMailStore
  attr_reader :root_path

  def initialize(root_path = Rails.root + 'data' + Rails.env + 'messages')
    @root_path = root_path
  end

  def include?(key)
    File.exist? key_path(key)
  end

  def [](key)
    if include?(key)
      Base64.strict_decode64(File.read(key_path(key)))
    end
  end

  def []=(key, value)
    FileUtils.mkdir_p File.dirname(key_path(key))
    File.write key_path(key), Base64.strict_encode64(value)
  end

  def values
    Dir["#{root_path}/**"].map do |path|
      Base64.strict_decode64(File.read(path))
    end
  end

  def key_path(key)
    File.expand_path(Digest::MD5.hexdigest(key.to_s), root_path)
  end
end