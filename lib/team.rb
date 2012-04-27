class Team
  def each_member
    passwords = ENV["PASSWORDS"].split(":")
    members = emails.zip(passwords)
    members.each do |(email, password)|
      yield email, password
    end
  end

  def has_member?(email)
    emails.include?(email)
  end

  private

  def emails
    ENV["TEAM"].split(":")
  end
end