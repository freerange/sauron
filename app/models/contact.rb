class Contact
  include Mongoid::Document
  has_and_belongs_to_many :messages

  has_many :sent_messages, class_name: "Message", inverse_of: :from
  has_and_belongs_to_many :received_messages, class_name: "Message", inverse_of: :to
  has_and_belongs_to_many :cc_d_messages, class_name: "Message", inverse_of: :cc

  field :email, type: String
  field :name, type: String
end  