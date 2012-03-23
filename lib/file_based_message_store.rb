require 'fileutils'

class FileBasedMessageStore
  def initialize(root_path)
    @root_path = root_path
  end

  def []=(key, value)
    full_path = File.expand_path(key, @root_path)
    FileUtils.mkdir_p File.dirname(full_path)
    File.write full_path, value
  end

  def values
    Dir["#{@root_path}/**"].map do |path|
      File.read(path)
    end
  end
end