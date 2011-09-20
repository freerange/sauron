require 'net/imap'

class GmailAccount
  include Mongoid::Document
  field :email
  field :password
  field :most_recent_uid

  GMAIL_HOST = 'imap.gmail.com'
  GMAIL_PORT = 993

  def login
    return if @logged_in
    @imap = Net::IMAP.new(GMAIL_HOST, GMAIL_PORT, ssl=true)
    @imap.login(email, password)
    possible_imap_roots = ["Gmail", "Google Mail"]
    imap_root = possible_imap_roots.find do |root|
      @imap.list("", "[#{root}]/%")
    end
    @imap.select("[#{imap_root}]/All Mail")
    @logged_in = true
  end

  def recent_uids
    login
    indexes = @imap.search("UID #{most_recent_uid || 1}:*")
    indexes_excluding_most_recent = indexes[1..-1]
    if indexes_excluding_most_recent.any?
      @imap.fetch(indexes_excluding_most_recent, "UID").map { |x| x.attr["UID"] }
    else
      []
    end
  end

  def load_message(uid)
    Sauron::RawMessage.new(@imap.uid_fetch([uid], "BODY[]")[0].attr["BODY[]"], uid)
  end

  def each_new_message(&block)
    login
    uids = recent_uids
    if uids.any?
      uids.each_slice(10) do |uid_slice|
        puts "#{self.email}: fetching #{uid_slice.inspect}"
        messages = messages_preserving_state(uid_slice)
        messages.each.with_index do |message, index|
          yield message.attr["BODY[]"], uid_slice[index]
        end
        update_attribute(:most_recent_uid, uid_slice.last)
      end
    end
  end

  def reset!
    update_attribute(:most_recent_uid, nil)
  end

  def messages_preserving_state(uid_slice)
    flags = @imap.uid_fetch(uid_slice, "FLAGS")
    messages = @imap.uid_fetch(uid_slice, "BODY[]")
    unread_messages = flags.reject { |f| f.attr["FLAGS"].include?(:Seen) }
    unread_message_uids = unread_messages.map { |f| f.attr["UID"] }
    @imap.uid_store(unread_message_uids, "-FLAGS", [:Seen])
    messages
  end
end