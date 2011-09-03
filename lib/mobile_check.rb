module ActionDispatch
  module MobileCheck
    SMART_PHONE_REGEXP = /iPhone|iPad|Android/
    IPHONE_REGEXP = /iPhone/
    IPAD_REGEXP = /iPad/

    def smart_phone?
      @env['HTTP_USER_AGENT'] =~ SMART_PHONE_REGEXP
    end

    def iphone?
      @env['HTTP_USER_AGENT'] =~ IPHONE_REGEXP
    end

    def ipad?
      @env['HTTP_USER_AGENT'] =~ IPAD_REGEXP
    end
  end
end

ActionDispatch::Request.send :include, ActionDispatch::MobileCheck
