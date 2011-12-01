class MessageThread
  include Mongoid::Document
  has_many :messages
  before_save :update_most_recent_message_at
  before_create :update_most_recent_message_at

  field :most_recent_message_at, type: Time

  default_scope order_by([[:most_recent_message_at, :desc]])

  def subject
    messages.first.subject
  end

  def contacts
    messages.map { |m| m.contacts }.flatten.uniq
  end

  private

  def update_most_recent_message_at
    self.most_recent_message_at = messages.first.date unless messages.first.nil?
  end
end