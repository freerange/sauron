class MessageThread
  include Mongoid::Document
  has_many :messages
  before_save :update_most_recent_message_at

  field :most_recent_message_at, type: Time

  default_scope order_by([[:most_recent_message_at, :desc]])

  def subject
    messages.first.subject
  end

  private

  def update_most_recent_message_at
    self.most_recent_message_at = messages.first.date
  end
end