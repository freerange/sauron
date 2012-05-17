namespace :reset do
  task :yes_i_am_really_sure => :environment do
    MessageRepository::ElasticSearchMessageIndex.new.reset!
    ConversationRepository::ConversationIndex::ActiveRecordStore.new.reset!
  end
end