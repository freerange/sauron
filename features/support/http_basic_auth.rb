def login
  ENV['HTTP_PASSWORD'] = 'password'
  page.driver.browser.authorize('admin', 'password')
end