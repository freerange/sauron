# The mail gem (and other places that attempt to handle multibyte encoding) use ActiveSupport to
# handle charset conversion.  Instances of ActiveSupport::Multibyte::Chars are used interchangeably
# with String, and most methods are indeed delegated to the underlying string.  However, #as_json
# is implemented in Object and this delegation fails:
#
#     "Tom".mb_chars.as_json # => {:wrapped_string => "Tom"}
#
# This has been fixed in ActiveSupport[1] but not yet released (as of version 3.2.3).
#
# [1] https://github.com/rails/rails/pull/4808

if ActiveSupport::Multibyte::Chars.instance_methods(false).include?(:as_json)
  raise "This patch to ActiveSupport::Multibyte::Chars is no longer required"
else
  class ActiveSupport::Multibyte::Chars
    def as_json(*args)
      to_s.as_json(*args)
    end
  end
end