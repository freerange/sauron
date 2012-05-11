message_repository = MessageRepository.new
message_index = message_repository.message_index
mail_store = message_repository.mail_store

records = message_index.where(in_reply_to: nil)
total = records.count

records.find_each do |record|
  message = MessageRepository::Message.new(message_index.find_primary_message_index_record(record.message_hash), mail_store)
  record.update_attribute(:in_reply_to, message.in_reply_to)
  puts "Updated #{record.id} of #{total}"
end