class MessageThread
  include Mongoid::Document
  has_many :messages

  def subject
    messages.first.subject
  end
end