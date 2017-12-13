module JdJropenSdk
  class Hapi
    attr_reader :customer_id, :default_params

    def initialize(mer_customer_id)
      @customer_id = mer_customer_id
      @default_params = {
        partnerId: JdJropenSdk.partner_id,
        appId: JdJropenSdk.app_id,
        sign: h5_sign,
        ver: JdJropenSdk.sdk_version,
        securityStr: encrypt_url_encode("#{h5_sign}_#{(Time.zone.now.to_f * 1000).to_i}")
      }
    end

    def enter_login_url
      params = {
        merCustomerId: customer_id,
        loginRole: "ENTER",
        componentCode: "SALARY_BALANCE"
      }
      params = default_params.merge params.transform_values { |v| encrypt_url_encode v }
      "#{JdJropenSdk.h5_host}?#{params.map { |k, v| "#{k}=#{v}" }.join('&')}"
    end

    def personal_login_url(partner_person_id, cert_no, user_name)
      params = {
        merCustomerId: partner_person_id,
        loginRole: "PERSONAL",
        componentCode: "PERSONAL_SALARY_IDX",
        extJson: { partnerMemberId: customer_id,
                   partnerPersonId: partner_person_id,
                   certNo:          cert_no,
                   userName:        user_name,
                   salaryAccType:   "XJK,CARD"
                 }.to_json
      }
      params = default_params.merge params.transform_values { |v| encrypt_url_encode v }
      "#{JdJropenSdk.h5_host}?#{params.map { |k, v| "#{k}=#{v}" }.join('&')}"
    end

    private

      def encrypt_url_encode(str)
        CGI::escape Security.encrypt(str)
      end

      def h5_sign
        @h5_sign ||= begin
          str = "CommonRequestHeader{&partnerId=#{JdJropenSdk.partner_id}&appId=#{JdJropenSdk.app_id}}"
          Security.generate_sign str, "MD5"
        end
      end
  end
end
