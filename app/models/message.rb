require 'mail'
require 'time'

class Message
  include Mongoid::Document
  belongs_to :message_thread
  belongs_to :in_reply_to, class_name: "Message", inverse_of: :replies
  has_many :replies, class_name: "Message", inverse_of: :in_reply_to

  has_and_belongs_to_many :contacts
  belongs_to :from, class_name: "Contact", inverse_of: :sent_messages
  has_and_belongs_to_many :to, class_name: "Contact", inverse_of: :received_messages
  has_and_belongs_to_many :cc, class_name: "Contact", inverse_of: :cc_d_messages

  default_scope order_by([[:date, :desc]])

  field :subject, type: String
  field :date, type: Time
  field :message_id, type: String
  field :headers, type: Hash
  field :multipart, type: Boolean
  field :parts, type: Array
  field :body, type: String

  index [[:date, Mongo::DESCENDING]]
  index [[:message_id, Mongo::ASCENDING]], unique: true
end