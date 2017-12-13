module JdJropenSdk
  class CommonResponse
    HEADER_KEYS = %w(sdkVersion version code msg partnerId merRequestNo charset signType encryptType encrypt).freeze

    attr_reader :header, :body

    def initialize(res_body)
      @res_body = JSON.parse res_body, object_class: HashWithIndifferentAccess
      if verify_sign
        body_str = Security.decrypt @res_body[:body]
        @body = JSON.parse body_str, object_class: HashWithIndifferentAccess
      end
    end

    def verify_sign
      @header = JSON.parse @res_body[:header], object_class: HashWithIndifferentAccess
      raise SdkException.new :mapi_partner_not_exit if @header[:msg] == "开发者不存在"

      header_str = HEADER_KEYS.map { |key| "#{key}=#{@header[key]}" }.join("&")
      Security.verify_sign header_str, @header[:sign], @header[:signType]
    end
  end
end
