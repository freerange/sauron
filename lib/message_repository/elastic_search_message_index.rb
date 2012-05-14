require 'tire'

class MessageRepository
  class ElasticSearchMessageIndex
    class SearchResult
      delegate :id, :message_id, :subject, :from, :recipients, :mail_identifier, to: :@item

      def initialize(item)
        @item = item
      end

      def to_hash
        @item.to_hash.select {|k, v| !k.to_s.starts_with?('_')}
      end

      def date
        Time.parse(@item.date)
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
      attributes[:mail_identifier] ||= [mail.account, mail.uid]
      attributes[:recipients] ||= []
      attributes[:recipients] += mail.delivered_to

      index.store attributes
      index.store type: 'mail_import', account: mail.account, uid: mail.uid
      index.refresh

      id
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

    def most_recent
      search = search_messages size: 500 do
        sort { by :date, :desc}
      end

      search.results.map do |result|
        SearchResult.new(result)
      end
    end

    def search(q)
      search = search_messages do
        query do
          string q
        end
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
            recipients: { type: 'string', index: 'not_analyzed' }
          }
        },

        mail_import: {
          properties: {
            account: { type: 'string', index: 'not_analyzed' },
            uid: { type: 'long' }
          }
        }
      }
      # It seems that after recreating the index we need to wait
      # some period of time before it is ready for searching.
      sleep 0.5
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