require 'mail'

class MessageRepository
  class Record < ActiveRecord::Base
    set_table_name :messages
  end

  class Message
    attr_reader :record
    delegate :subject, :date, :from, to: :record

    def initialize(record)
      @record = record
    end

    def ==(message)
      message.is_a?(Message) &&
      message.record == record
    end
  end

  class << self
    attr_writer :instance

    delegate :add, :exists?, :messages, to: :instance

    def instance
      @instance ||= new
    end
  end

  attr_reader :model

  def initialize(model = Record)
    @model = model
  end

  def add(uid, message)
    mail = Mail.new(message)
    @model.create! uid: uid, subject: mail.subject, date: mail.date, from: mail.from.first
  end

  def exists?(uid)
    @model.where(uid: uid).exists?
  end

  def messages
    @model.all.map do |record|
      Message.new record
    end
  end
end