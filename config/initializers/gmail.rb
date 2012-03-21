require 'gmail_account'

GmailAccount.email = (ENV["EMAIL"] || "").strip
GmailAccount.password = (ENV["PASSWORD"] || "").strip