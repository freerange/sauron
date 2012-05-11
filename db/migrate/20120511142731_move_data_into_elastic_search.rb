class MoveDataIntoElasticSearch < ActiveRecord::Migration
  def up
    MessageRepository::ElasticSearchMessageIndex.new.reset!

    MessageRepository::ActiveRecordMessageIndex.find_in_batches(batch_size: 100) do |messages|
      index = Tire::Index.new("sauron-#{Rails.env}")

      messages.each do |message|
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

      puts "Imported batch of messages #{messages.first.id} => #{messages.last.id}"

      sleep 3
    end
  end

  def down
  end
end
