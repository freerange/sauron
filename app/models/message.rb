require 'mail'
require 'time'

class Message
  include Mongoid::Document
  belongs_to :message_thread
  has_and_belongs_to_many :contacts

  field :to, type: String
  field :from, type: String
  field :subject, type: String
  field :date, type: Time
  field :message_id, type: String
  field :headers, type: Hash
  field :multipart, type: Boolean
  field :parts, type: Array
  field :body, type: String

  index [[:message_id, Mongo::ASCENDING]], unique: true
end