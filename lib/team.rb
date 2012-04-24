class Team
  def initialize(emails_vs_passwords = {})
    @emails_vs_passwords = emails_vs_passwords
  end

  def each_member
    @emails_vs_passwords.each do |(email, password)|
      yield email, password
    end
  end
end