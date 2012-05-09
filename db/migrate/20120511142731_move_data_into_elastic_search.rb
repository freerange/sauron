class MoveDataIntoElasticSearch < ActiveRecord::Migration
  def up
    MessageRepository::ElasticSearchMessageIndex.new.reset!

    index = Tire::Index.new("sauron-#{Rails.env}")

    MessageRepository::ActiveRecordMessageIndex.all.each do |message|
      index.store(
        id: message.message_hash,
        type: 'message',
        message_id: message.message_id,
        subject: message.subject,
        date: message.date,
        from: message.from,
        mail_identifier: message.mail_identifier,
        recipients: message.recipients
      )

      message.mail_index_records.each do |index_record|
        index.store(
          type: 'mail_import',
          account: index_record.account,
          uid: index_record.uid
        )
      end
    end
  end

  def down
  end
end
