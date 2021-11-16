require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Slack < OmniAuth::Strategies::OAuth2
      option :client_options, site: 'https://slack.com', token_url: 'api/oauth.access'

      uid do
        raw_info.dig('user', 'id')
      end

      info do
        {
          name: raw_info.dig('user', 'name'),
          email: raw_info.dig('user', 'email')
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('/api/users.identity').parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end