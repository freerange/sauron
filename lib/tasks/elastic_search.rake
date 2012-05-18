namespace :elastic_search do
  namespace :test do
    task :prepare do
      require 'message_repository/elastic_search_message_index'
      # Note, Rails.env is incorrect at this point, so hardcoding index name
      MessageRepository::ElasticSearchMessageIndex.new('sauron-test').reset!
    end
  end
end

task :test => 'elastic_search:test:prepare'
task :cucumber => 'elastic_search:test:prepare'