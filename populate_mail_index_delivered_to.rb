MessageRepository::ActiveRecordMailIndex.where("delivered_to IS NULL").find_each do |record|
  raw_message = CacheBackedMailStore.find(record.account, record.uid)
  mail = Mail.new(raw_message)
  delivered_to = mail['Delivered-To'].to_s
  record.update_attributes!(delivered_to: delivered_to)
end
