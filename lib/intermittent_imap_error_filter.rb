class IntermittentImapErrorFilter
  class KnownError < RuntimeError
    attr_reader :original_error

    def initialize(original_error=nil)
      @original_error = original_error
    end

    def message
      original_error ? original_error.message : super
    end

    def to_s
      original_error ? original_error.to_s : super
    end

    def backtrace
      original_error ? original_error.backtrace : super
    end
  end

  def initialize
    begin
      yield
    rescue Net::IMAP::NoResponseError => e
      if e.message == 'System error (Failure)'
        raise KnownError.new(e)
      else
        raise e
      end
    rescue Net::IMAP::ByeResponseError => e
      case e.message
      when 'System error', 'Temporary System Error'
        raise KnownError.new(e)
      else
        raise e
      end
    end
  end
end
