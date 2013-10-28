require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Idnet < OmniAuth::Strategies::OAuth2

      option :name, "idnet"

      option :fields, OmniAuth::Idnet::DEFAULT

      option :client_options, {
        :site => "https://www.id.net",
        :ssl => { verify: true }
      }

      option :authorize_options, [:scope, :display]

      uid { raw_info['pid'] }

      info do
        options.fields.inject({}) do |hash, field|
          hash[field] = raw_info[field.to_s]
          hash
        end
      end

      def raw_info
        @raw_info ||= access_token.get('/api/profile').parsed
      end

      def authorize_params
        super.tap do |params|
          if Enumerable === request.params['prefill']
            request.params['prefill'].each do |key, value|
              params.merge!(("prefill[" + key.to_s + "]").to_sym => value)
            end
          end
          if Enumerable === request.params['meta']
            request.params['meta'].each do |key, value|
              params.merge!(("meta[" + key.to_s + "]").to_sym => value)
            end
          end
        end
      end
    end
  end
end
