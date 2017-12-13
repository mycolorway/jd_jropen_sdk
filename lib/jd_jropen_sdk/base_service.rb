require "rest-client"

module JdJropenSdk
  module BaseService
    def post(path, body = {})
      request = CommonRequest.new body
      response = client[path].post request.payload
      if response.code == 200
        CommonResponse.new response.body
      else
        response
      end
    end

    def client
      @client ||= RestClient::Resource.new JdJropenSdk.api_host, **JdJropenSdk.http_options
    end
  end
end
