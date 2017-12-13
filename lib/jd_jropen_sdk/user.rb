module JdJropenSdk
  module User
    include JdJropenSdk::BaseService
    extend self

    def query_cert_auth_status(partner_person_id)
      # 查询用户身份证照片审核结果接口
      # partner_person_id: 商户平台的个人用户 id
      post "/mapi/aop/salary/queryCertAuthStatus", partnerPersonId: partner_person_id
    end
  end
end
