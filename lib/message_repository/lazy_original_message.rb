class MessageRepository::LazyOriginalMessage
  def initialize(account, uid, store)
    @account = account
    @uid = uid
    @store = store
  end

  def to_s
    @message ||= @store.find(@account, @uid)
  end
end