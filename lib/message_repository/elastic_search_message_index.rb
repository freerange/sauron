require 'tire'

class MessageRepository
  class ElasticSearchMessageIndex
    class SearchResult
      delegate :id, :subject, :from, :to, :cc, :body, :recipients, :mail_identifier, to: :@item

      def initialize(item)
        @item = item
      end

      def to_hash
        @item.to_hash.select {|k, v| !k.to_s.starts_with?('_')}
      end

      def date
        Time.parse(@item.date)
      end

      def message_id
        if @item.message_id.is_a?(Tire::Results::Item)
          @item.message_id.wrapped_string
        else
          @item.message_id
        end
      end

      def message_hash
        id
      end
    end

    def ==(object)
      object.is_a?(self.class)
    end

    def add(mail)
      id = Digest::SHA1.hexdigest(mail.message_id)

      existing_message = find(id)
      attributes = existing_message ? existing_message.to_hash : {}

      attributes[:id] = id
      attributes[:type] = 'message'
      attributes[:message_id] = mail.message_id
      attributes[:subject] = mail.subject
      attributes[:date] = mail.date
      attributes[:from] = mail.from
      attributes[:to] = mail.to
      attributes[:cc] = mail.cc
      attributes[:body] = mail.body
      attributes[:mail_identifier] ||= [mail.account, mail.uid]
      attributes[:recipients] ||= []
      attributes[:recipients] += mail.delivered_to

      index.store attributes
      index.store type: 'mail_import', account: mail.account, uid: mail.uid
      index.refresh

      find(id)
    end

    def find(id)
      results = search_messages size: 1 do
        query do
          term :id, id
        end
      end
      results.first && SearchResult.new(results.first)
    end

    def find_by_message_hash(hash)
      find(hash)
    end

    def mail_exists?(account, uid)
      search_mail_imports size: 1 do
        query do
          boolean do
            must { term :account, account }
            must { term :uid, uid }
          end
        end
      end.first
    end

    def highest_uid(account)
      results = search_mail_imports size: 1 do
        query do
          boolean do
            must { term :account, account }
          end
        end
        sort { by :uid, :desc }
      end

      results.first && results.first.uid
    end

    def most_recent(number_of_messages, options = {})
      excluding = options[:excluding] || []
      search = search_messages size: number_of_messages do
        unless excluding.empty?
          query do
            boolean do
              excluding.each do |address|
                must_not { string "from:#{address}" }
              end
            end
          end
        end
        sort { by :date, :desc}
      end

      search.results.map do |result|
        SearchResult.new(result)
      end
    end

    def search(q)
      search = search_messages size: 500 do
        query do
          boolean do
            should { text :from, q }
            should { text :to, q }
            should { text :cc, q }
            should { text :subject, q }
            should { text :body, q }
          end
        end
        sort { by :date, :desc }
      end

      search.results.map do |result|
        SearchResult.new(result)
      end
    end

    def reset!
      index.delete
      index.create mappings: {
        message: {
          properties: {
            message_id: { type: 'string', index: 'not_analyzed' },
            date: { type: 'date' },
            recipients: { type: 'string', index: 'not_analyzed' },
            from: { type: 'string', index: 'not_analyzed' },
            to: { type: 'string', index: 'not_analyzed' },
            cc: { type: 'string', index: 'not_analyzed' }
          }
        },

        mail_import: {
          properties: {
            account: { type: 'string', index: 'not_analyzed' },
            uid: { type: 'long' }
          }
        }
      }
      index.refresh
    end

    private

    def index
      @index ||= Tire::Index.new "sauron-#{Rails.env}"
    end

    def search_messages(options = {}, &block)
      search_type 'message', options, &block
    end

    def search_mail_imports(options = {}, &block)
      search_type 'mail_import', options, &block
    end

    def search_type(type, options, &block)
      Tire.search(index.name + '/' + type, options, &block).results
    end
  end
end