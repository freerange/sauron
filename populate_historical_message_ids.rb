max_id = MessageRepository::ActiveRecordMessageIndex.maximum(:id)

MessageRepository::ActiveRecordMessageIndex.where("message_id IS NULL").find_each do |record|
  message = MessageRepository::LazyOriginalMessage.new(record.account, record.uid, CacheBackedMessageStore)
  mail = Mail.new(message.to_s)
  record.update_attribute(:message_id, mail.message_id)
  puts "Updated #{record.id} of #{max_id}"
end