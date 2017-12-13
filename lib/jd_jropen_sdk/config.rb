require "openssl"

module JdJropenSdk
  class << self
    def configure(&block)
      yield config
    end

    def config
      @config ||= Config.new
    end

    def method_missing(method, *args, &block)
      if args.empty?
        config.send method
      else
        super
      end
    end
  end

  class Config
    API_HOST = "http://ft.jdpay.com".freeze
    API_VERSION = "1.0.0".freeze
    ENCRYPT_TYPE = "3DES".freeze
    H5_HOST = "http://ft.jdpay.com/hapi/sign/loginIn".freeze

    attr_accessor :app_id, :partner_id, :sdk_version, :api_version, :api_host, :h5_host,
                  :encrypt_type, :tdes_key, :md5_key, :pfx_path, :pfx_psw, :jropen_cer_key, :sftp_host, :sftp_cert_path,
                  :http_options, :config_path

    def initialize
      @sdk_version = JdJropenSdk::VERSION
      @api_version = API_VERSION
      @api_host = API_HOST
      @h5_host = H5_HOST
      @encrypt_type = ENCRYPT_TYPE
      @http_options = { verify_ssl: OpenSSL::SSL::VERIFY_NONE, open_timeout: 10 }
    end

    def config_path=(config_path)
      raise MissingFileError, "Jd jropen config file is missing" unless File.exist?(config_path)
      raw_data = YAML.load ERB.new(File.read config_path).result
      configs = raw_data.fetch(env, raw_data)
      raise("Jd jropen configuration is invalid.") if configs.blank?
      configs.each { |key, value| send "#{key}=", value if respond_to? "#{key}=" }
    end

    def http_options=(options)
      @http_options = @http_options.merge options
    end

    def sftp_ip
      @sftp_host.split(":").first
    end

    def sftp_port
      @sftp_host.split(":").last || 2000
    end

    def env
      return Rails.env.to_s if defined? Rails
      return Rack.env.to_s if defined? Rack
    end
  end
end
