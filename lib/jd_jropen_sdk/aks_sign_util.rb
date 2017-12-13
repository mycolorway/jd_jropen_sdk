module JdJropenSdk
  module AksSignUtil
    def sign_envelop(data)
      signed_bytes = sign data
      enveloped_bytes = encrypt_envelop signed_bytes
      Base64.strict_encode64 enveloped_bytes
    end

    def verify_envelop(envelop_data)
      enveloped_bytes = Base64.decode64 envelop_data
      signed_bytes = decrypt_envelop enveloped_bytes
      verify_attach_sign signed_bytes
    end

    def sign(data)
      data = data.force_encoding("UTF-8")
      signed_data = OpenSSL::PKCS7::sign partner_cert, partner_key, data, [partner_cert], OpenSSL::PKCS7::BINARY
      signed_data.to_der
    end

    def verify_attach_sign(signed_bytes)
      p7_sign = OpenSSL::PKCS7.new(signed_bytes)
      p7_sign.verify(nil, cert_store, nil, OpenSSL::PKCS7::NOVERIFY)
      p7_sign.data
    end

    def encrypt_envelop(original_bytes)
      enveloped_data = OpenSSL::PKCS7::encrypt(
        [jropen_cert],
        original_bytes,
        OpenSSL::Cipher::new("DES-EDE3-CBC"),
        OpenSSL::PKCS7::BINARY
      )
      enveloped_data.to_der
    end

    def decrypt_envelop(enveloped_bytes)
      envelop = OpenSSL::PKCS7.new enveloped_bytes
      envelop.decrypt partner_key, partner_cert
    end

    private

      def partner_cert
        @pkcs ||= OpenSSL::PKCS12.new(File.read(JdJropenSdk.pfx_path), JdJropenSdk.pfx_psw)
        @pkcs.certificate
      end

      def partner_key
        @pkcs ||= OpenSSL::PKCS12.new(File.read(JdJropenSdk.pfx_path), JdJropenSdk.pfx_psw)
        @pkcs.key
      end

      def jropen_cert
        @jropen_cert ||= OpenSSL::X509::Certificate.new Base64.decode64(JdJropenSdk.jropen_cer_key)
      end

      def cert_store
        @cert_store ||= begin
          cert_store = OpenSSL::X509::Store.new
          cert_store.add_cert(partner_cert)
        end
      end
  end
end
