require "test_helper"

class IntermittentImapErrorFilterTest < ActiveSupport::TestCase
  test "should re-raise errors caused by IMAP response 'NO System error (Failure)' as KnownError" do
    assert_raises(IntermittentImapErrorFilter::KnownError) do
      IntermittentImapErrorFilter.new do
        raise Net::IMAP::NoResponseError.new(stub('response', name: 'NO', data: stub('data', text: 'System error (Failure)')))
      end
    end
  end

  test "should re-raise errors caused by IMAP response 'NO some other message' as they were" do
    assert_raises(Net::IMAP::NoResponseError) do
      IntermittentImapErrorFilter.new do
        raise Net::IMAP::NoResponseError.new(stub('response', name: 'NO', data: stub('data', text: 'some other message')))
      end
    end
  end

  test "should re-raise errors caused by IMAP response 'BYE System error' as KnownError" do
    assert_raises(IntermittentImapErrorFilter::KnownError) do
      IntermittentImapErrorFilter.new do
        raise Net::IMAP::ByeResponseError.new(stub('response', name: 'BYE', data: stub('data', text: 'System error')))
      end
    end
  end

  test "should re-raise errors caused by IMAP response 'BYE some other message' as they were" do
    assert_raises(Net::IMAP::ByeResponseError) do
      IntermittentImapErrorFilter.new do
        raise Net::IMAP::ByeResponseError.new(stub('response', name: 'BYE', data: stub('data', text: 'some other message')))
      end
    end
  end

  test "should re-raise errors caused by IMAP response 'BYE Temporary System Error' as KnownError" do
    assert_raises(IntermittentImapErrorFilter::KnownError) do
      IntermittentImapErrorFilter.new do
        raise Net::IMAP::ByeResponseError.new(stub('response', name: 'BYE', data: stub('data', text: 'Temporary System Error')))
      end
    end
  end

  test "should re-raise errors caused by IAMP response 'BYE System Error p34if2288003weq.91' (or thereabouts) as KnownError" do
    assert_raises(IntermittentImapErrorFilter::KnownError) do
      IntermittentImapErrorFilter.new do
        raise Net::IMAP::ByeResponseError.new(stub('response', name: 'BYE', data: stub('data', text: 'u47if2308312wes.68')))
      end
    end

    assert_raises(IntermittentImapErrorFilter::KnownError) do
      IntermittentImapErrorFilter.new do
        raise Net::IMAP::ByeResponseError.new(stub('response', name: 'BYE', data: stub('data', text: 'h54if230849wec.1')))
      end
    end
  end

  test "should re-raise other errors transparently" do
    assert_raises(RuntimeError) do
      IntermittentImapErrorFilter.new { raise RuntimeError }
    end
  end

  test "should re-raise known errors with the same message and backtrace as original errors" do
    original_error = Net::IMAP::ByeResponseError.new(stub('response', name: 'BYE', data: stub('data', text: 'System failure')))
    e = IntermittentImapErrorFilter::KnownError.new(original_error)
    assert_equal original_error.message, e.message
    assert_equal original_error.backtrace, e.backtrace
  end
end
