MailRepository::ActiveRecordMailIndex.where("message_hash IS NULL").find_each do |record|
  hash = if record.message_id
    Digest::SHA1.hexdigest(record.message_id)
  else
    Digest::SHA1.hexdigest(record.from + record.date.to_s + record.subject)
  end
  record.update_attribute(:message_hash, hash)
end