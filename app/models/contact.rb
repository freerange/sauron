class Contact
  include Mongoid::Document
  has_and_belongs_to_many :messages

  field :email, type: String
  field :name, type: String
end  