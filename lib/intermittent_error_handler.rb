class IntermittentErrorHandler
  FILENAME = "previous_error"

  def self.reset!
    File.unlink(FILENAME) if File.exists?(FILENAME)
  end

  attr_reader :logger

  def initialize(logger = nil)
    @logger = logger
    begin
      yield
      clear_previous_error
    rescue IntermittentImapErrorFilter::KnownError => e
      if previously_caught_error?(e)
        log_error("Caught error a second time", e)
        raise e
      else
        note_error(e)
        log_error("Caught intermittent error", e)
      end
    end
  end

  private

  def previously_caught_error?(e)
    File.exists?(FILENAME) && (File.read(FILENAME) == e.to_s)
  end

  def note_error(e)
    File.open(FILENAME, "w") { |f| f.write e.to_s }
  end

  def clear_previous_error
    File.unlink(FILENAME) if File.exists?(FILENAME)
  end

  def log_error(message, e)
    if logger
      logger.info(message)
      logger.info(e)
      logger.info(e.backtrace)
    end
  end
end
