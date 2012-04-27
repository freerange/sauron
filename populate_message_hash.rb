MessageRepository::ActiveRecordMailIndex.where("message_hash IS NULL").find_each do |record|
  hash = if record.message_id
    Digest::SHA1.hexdigest(record.message_id)
  else
    Digest::SHA1.hexdigest(record.from.to_s + record.date.to_s + record.subject.to_s)
  end
  record.update_attribute(:message_hash, hash)
end