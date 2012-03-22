require 'test_helper'

#messages
#store(message)

class FileBasedMessageStore
  def initialize(root_path)
  end
end

class FileBasedMessageStoreTest < ActiveSupport::TestCase
  test 'stores messages in directory on filesystem' do
    root_path = 'test'
    store = FileBasedMessageStore.new(root_path)
    pending
  end

  test 'retrieves all messages from the directory' do
    pending
  end
end
