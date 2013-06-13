require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Idaas < OmniAuth::Strategies::OAuth2
      option :name, "idaas"
      option :client_options, {
        :site          => 'https://cloudoesecurity.w3.bluemix.net',
        :authorize_url => '/sps/oauth20sp/oauth20/authorize',
        :token_url     => '/sps/oauth20sp/oauth20/token',
        :profile_url   => '/idaas/resources/profile.jsp',
      }
      option :scope, 'profile'

      uid { raw_info['uid'].to_s }

      info do
        {
          'nickname' => (raw_info['notesShortName'] && raw_info['notesShortName'][0]) || (raw_info['notesshortname'] && raw_info['notesshortname'][0]),
          'name'     => ((raw_info['notesEmail'] && raw_info['notesEmail'][0]) || (raw_info['notesemail'] && raw_info['notesemail'][0])).gsub(/CN=([\w ]+)\/.*/, '\1'),
          'email'    => raw_info['username'],
        }
      end

      extra do
        {:raw_info => raw_info}
      end

      def raw_info
        @raw_info ||= MultiJson.load(access_token.get(options.client_options[:profile_url], :access_token => access_token.token).body)
      rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end
    end
  end
end
