require 'fileutils'

class FileBasedMessageStore
  def initialize(root_path)
    @root_path = root_path
  end

  def include?(key)
    File.exist? key_path(key)
  end

  def []=(key, value)
    FileUtils.mkdir_p File.dirname(key_path(key))
    File.write key_path(key), value
  end

  def values
    Dir["#{@root_path}/**"].map do |path|
      File.read(path)
    end
  end

  private

  def key_path(key)
    File.expand_path(key.to_s, @root_path)
  end
end