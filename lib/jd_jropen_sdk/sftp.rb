module JdJropenSdk
  module Sftp
    include AksSignUtil
    extend self

    def encrypt_salary_file_upload(file_path, file_name, salary_str)
      encrypted_str = Security.encrypt salary_str
      end_str = sign_envelop encrypted_str
      upload_file file_path, file_name, end_str
    end

    def download_salary_file_decrypt(file_path, file_name)
      end_str = download_file file_path, file_name
      encrypted_str = verify_envelop end_str
      Security.decrypt encrypted_str
    end

    def upload_file(file_path, file_name, file_str)
      sftp_start do |sftp|
        sftp.file.open(File.join(file_path, file_name), "w") { |f| f.puts file_str }
      end
      Security.generate_sign file_str, "MD5"
    end

    def download_file(file_path, file_name)
      file_str = ""
      sftp_start do |sftp|
        sftp.file.open(File.join(file_path, file_name), "r") { |f| file_str = f.gets }
      end
      file_str
    end

    def sftp_start(&block)
      return unless block_given?
      Net::SFTP.start(JdJropenSdk.sftp_ip,
                      JdJropenSdk.partner_id,
                      keys: JdJropenSdk.sftp_cert_path,
                      port: JdJropenSdk.sftp_port) do |sftp|
        block.call(sftp)
      end
    end
  end
end
