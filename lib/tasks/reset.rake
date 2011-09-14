namespace :dangerously do
  task :reset => :environment do
    Message.delete_all
    MessageThread.delete_all
    Contact.delete_all
    GmailAccount.update(most_recent_uid: nil)
  end
end