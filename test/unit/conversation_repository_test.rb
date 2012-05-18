require 'test_helper'

class ConversationRepositoryTest < ActiveSupport::TestCase
  test 'retrieves the most recent conversations from the conversation index' do
    conversation_1 = stub('conversation-1', subject: 'subject-1')
    conversation_2 = stub('conversation-2', subject: 'subject-2')
    index = stub('index', most_recent: [conversation_1, conversation_2])
    repository = ConversationRepository.new(index)

    conversations = repository.conversations

    assert_same_elements ['subject-1', 'subject-2'], conversations.map(&:subject)
  end
end
