module JdJropenSdk
  class AsyncMessage
    HEADER_KEYS = %w(messageType messageVersion messageSendNo messageSendTime charset signType encryptType).freeze
    attr_reader :request
    attr_accessor :response

    def initialize(request_params)
      body_str = Security.decrypt request_params[:body]
      @request = {
        header: JSON.parse(request_params[:header], object_class: HashWithIndifferentAccess),
        body: JSON.parse(body_str, object_class: HashWithIndifferentAccess)
      }
      @response = {}
    end

    def verify_sign
      header_str = HEADER_KEYS.map { |key| "#{key}=#{request[:header][key]}" }.join("&")
      Security.verify_sign header_str, request[:header][:sign], request[:header][:signType]
    end

    def build_response(resp_status:, resp_msg:, ext_map:)
      headers = request[:header]
      header_str = HEADER_KEYS.map { |key| "#{key}=#{headers[key]}" }.join("&")
      headers[:sign] = Security.generate_sign header_str, headers[:signType]
      body = { respStatus: resp_status, respMsg: resp_msg, extMap: ext_map }
      @response = {
        header: headers.to_json,
        body: Security.encrypt(body.to_json)
      }
    end
  end
end
