require 'httparty'

class MessageRepository::ElasticSearchMessageIndex
  include ::HTTParty

  base_uri 'http://localhost:9200'

  class Result
    def initialize(attributes)
      @attributes = attributes
    end

    [:account, :uid, :subject, :from].each do |attribute|
      define_method attribute do
        @attributes[attribute.to_s]
      end
    end

    def date
      Time.parse(@attributes["date"])
    end

    def to_param
      @attributes["key"]
    end
  end

  class << self
    def most_recent
      result = get(messages_path + '/_search', body: {size: 500, sort: [{date: 'desc'}]}.to_json)
      result["hits"]["hits"].map do |r|
        Result.new(r["_source"])
      end
    end

    def find(key)
      result = get message_path(key)
      if result["exists"]
        Result.new(result["_source"])
      end
    end

    def message_exists?(account, uid)
      result = get(messages_path + '/_search', body: {size: 1, query: {term: {uid: uid, account: account}}}.to_json)
      p result
      result["hits"]["total"] == 1
    end

    def highest_uid(account)
      result = get(messages_path + '/_search', body: {size: 1, sort: [{uid: 'desc'}], query: {term: {account: account}}}.to_json)
      result["hits"]["hits"].first && result["hits"]["hits"].first["_source"]["uid"]
    end

    def add(message)
      existing = get(messages_path + '/_search', body: {size: 1, query: {term: {message_id: message.message_id}}}.to_json)
      if existing["hits"]["total"] == 0
        attributes = json_for(message)
        put message_path(attributes[:key]), body: attributes.to_json
        post "#{root_path}/_refresh"
        attributes[:key]
      end
    end

    def destroy
      delete messages_path
      put root_path
      put "#{messages_path}/_mapping", :body => {
        nodes: {
          properties: {
            account: {type: 'string', index: 'not_analyzed'},
            uid: {type: 'long'},
            message_id: {type: 'string', index: 'not_analyzed'}
          }
        }
      }.to_json
    end

    def json_for(message)
      {
        account: message.account,
        uid: message.uid,
        subject: message.subject,
        date: message.date,
        from: message.from,
        key: Sauron::Random.base62(24),
        message_id: message.message_id
      }
    end

    def root_path
      "/sauron-#{Rails.env}"
    end

    def messages_path
      "#{root_path}/messages"
    end

    def message_path(key)
      "#{messages_path}/#{key}"
    end
  end
end