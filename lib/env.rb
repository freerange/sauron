class Env
  def initialize(env = ENV)
    @env = env
  end

  def email
    @env["EMAIL"]
  end

  def password
    @env["PASSWORD"]
  end

  def emails
    extract_string_array(@env["TEAM"])
  end

  def passwords
    extract_string_array(@env["PASSWORDS"])
  end

  def emails_vs_passwords
    Hash[*emails.zip(passwords).flatten]
  end

  private

  def extract_string_array(variable)
    variable.split(":")
  end
end
