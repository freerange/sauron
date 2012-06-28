require "test_helper"

class IntermittentErrorHandlerTest < ActiveSupport::TestCase
  setup do
    IntermittentErrorHandler.reset!
  end

  test "should re-raise errors caused by unknown errors" do
    assert_raises(RuntimeError) do
      IntermittentErrorHandler.new { raise RuntimeError }
    end
  end

  test "should not re-raise errors caused by known intermittent errors" do
    assert_nothing_raised do
      IntermittentErrorHandler.new { raise IntermittentImapErrorFilter::KnownError }
    end
  end

  test "should log errors caused by known intermittent errors" do
    logger = stub('logger')
    logger.expects(:info).at_least_once
    IntermittentErrorHandler.new(logger) { raise IntermittentImapErrorFilter::KnownError }
  end

  test "should not re-raise errors caused by known intermittent errors if two are raised non-consecutively" do
    assert_nothing_raised do
      IntermittentErrorHandler.new { raise IntermittentImapErrorFilter::KnownError }
      IntermittentErrorHandler.new do
        # nothing
      end
      IntermittentErrorHandler.new { raise IntermittentImapErrorFilter::KnownError }
    end
  end

  test "should re-raise errors caused by known intermittent errors if two are raised consecutively" do
    assert_raises(IntermittentImapErrorFilter::KnownError) do
      IntermittentErrorHandler.new { raise IntermittentImapErrorFilter::KnownError }
      IntermittentErrorHandler.new { raise IntermittentImapErrorFilter::KnownError }
    end
  end
end
