module JdJropenSdk
  module Salary
    include BaseService
    extend self

    def query_acc_info(partner_person_id)
      # 查询用户发薪设置信息接口
      # partner_person_id: 商户平台的个人用户 id
      post "/mapi/aop/salary/queryAccInfo", partnerPersonId: partner_person_id
    end

    def salary_file_notify(mer_customer_id, batch_file_path, batch_file_name, batch_file_md5)
      # 执行发薪操作通知接口
      # mer_customer_id: 商户发薪主体编号 (商户平台的用户 id)
      # batch_file_path: sftp根目录相对路径
      # batch_file_name: 文件名，格式: YYYYMMDD_merCustormId_partnerBatchNo.txt例如20170808（当天时间）_xxx_2017001.txt，商户的批次号必须保证唯一
      # batch_file_md5: 文件内容的的MD5，为了校验文件的完整性和唯一性
      body = {
        merCustomerId: mer_customer_id,
        batchFilePath: batch_file_path,
        batchFileName: batch_file_name,
        batchFileMd5: batch_file_md5
      }
      post "/mapi/aop/salary/salaryFileNotify", body
    end

    def query_salary_order(partner_batch_no, partner_order_no)
      # 查询发薪记录信息
      # partner_batch_no: 商户平台工资唯一批次号
      # partner_order_no: 商户平台唯一订单号
      post "/mapi/aop/salary/queryOrder", partnerBatchNo: partner_batch_no, partnerOrderNo: partner_order_no
    end
  end
end
