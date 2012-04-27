def login
  ENV['TEAM'] = 'alice@example.com'
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('alice@example.com', 'password')
end