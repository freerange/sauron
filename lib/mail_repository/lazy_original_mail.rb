class MailRepository::LazyOriginalMail
  def initialize(account, uid, store)
    @account = account
    @uid = uid
    @store = store
  end

  def to_s
    @mail ||= @store.find(@account, @uid)
  end
end