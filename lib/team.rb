class Team
  def each_member
    emails = ENV["TEAM"].split(":")
    passwords = ENV["PASSWORDS"].split(":")
    members = emails.zip(passwords)
    members.each do |(email, password)|
      yield email, password
    end
  end

  def has_member?(email)
    emails = ENV["TEAM"].split(":")
    emails.include?(email)
  end
end