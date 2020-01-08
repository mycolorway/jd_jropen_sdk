module JdJropenSdk
  class CommonRequest
    ENCRYPT_TYPE = "3DES".freeze
    CHARSET = "UTF-8".freeze

    attr_accessor :body, :header

    def initialize(body = {})
      @body = body
    end

    def generate_header
      headers = {
        sdkVersion: JdJropenSdk.sdk_version,
        version: JdJropenSdk.api_version,
        partnerId: JdJropenSdk.partner_id,
        appId: JdJropenSdk.app_id,
        merRequestNo: "REQ#{SecureRandom.hex(4)}#{(Time.zone.now.to_f * 1000).to_i}",
        merRequestTime: Time.zone.now.strftime("%Y%m%d%H%M%S"),
        charset: CHARSET,
        signType: JdJropenSdk.sign_type,
        encryptType: ENCRYPT_TYPE,
        encrypt: Security.encrypt(@body.to_json)
      }
      header_str = headers.map { |k, v| "#{k}=#{v}" }.join("&")
      headers.merge sign: Security.generate_sign(header_str, JdJropenSdk.sign_type)
    end

    def payload
      headers = generate_header
      { header: headers.to_json, body: headers[:encrypt] }.to_json
    end
  end
end
