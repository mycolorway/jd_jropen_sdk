module JdJropenSdk
  module Security
    include AksSignUtil
    extend self

    TRIPLEDES_ALGORITHM_MODE = "DES-EDE3".freeze

    def encrypt(str)
      cipher = OpenSSL::Cipher.new TRIPLEDES_ALGORITHM_MODE
      cipher.encrypt
      cipher.key = JdJropenSdk.tdes_key
      result = cipher.update(str.force_encoding("UTF-8")) + cipher.final
      # Base64.strict_encode64 result
      # Just make result looks like java
      [result].pack("m58")
    end

    def decrypt(str)
      str = Base64.decode64 str.force_encoding("UTF-8")
      cipher = OpenSSL::Cipher.new TRIPLEDES_ALGORITHM_MODE
      cipher.key = JdJropenSdk.tdes_key
      cipher.decrypt
      result = cipher.update(str) + cipher.final
      result.force_encoding("UTF-8")
    end

    def generate_sign(str, sign_type)
      case sign_type.to_s
      when "MD5"
        Digest::MD5.hexdigest(str + JdJropenSdk.md5_key).upcase
      when "CERT"
        sign_envelop encrypt(str)
      else
        #
      end
    end

    def verify_sign(str, sign, sign_type)
      case sign_type.to_s
      when "MD5"
        curr_sign = Digest::MD5.hexdigest(str + JdJropenSdk.md5_key)
        curr_sign.upcase == sign.upcase
      when "CERT"
        curr_sign = verify_envelop(sign)
        decrypt(curr_sign).downcase == str.downcase
      else
        #
      end
    end
  end
end
