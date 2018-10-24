# frozen_string_literal: true

# rubocop:disable all
# This is copied from `rack-test` and monkey-patches an issue with it
# overwriting valid `multipart/*` content types in tests.
# See https://github.com/rack-test/rack-test/pull/238 for more information
# and the progress of the PR.
module Rack
  module Test
    class Session
      private

      def env_for(uri, env)
        env = default_env.merge(env)

        env['HTTP_HOST'] ||= [uri.host, (uri.port if uri.port != uri.default_port)].compact.join(':')

        env.update('HTTPS' => 'on') if URI::HTTPS === uri
        env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest' if env[:xhr]

        # TODO: Remove this after Rack 1.1 has been released.
        # Stringifying and upcasing methods has be commit upstream
        env['REQUEST_METHOD'] ||= env[:method] ? env[:method].to_s.upcase : 'GET'

        params = env.delete(:params) do {} end

        if env['REQUEST_METHOD'] == 'GET'
          # merge :params with the query string
          if params
            params = parse_nested_query(params) if params.is_a?(String)

            uri.query = [uri.query, build_nested_query(params)].compact.reject { |v| v == '' }.join('&')
          end
        elsif !env.key?(:input)
          env['CONTENT_TYPE'] ||= 'application/x-www-form-urlencoded'

          if params.is_a?(Hash)
            if data = build_multipart(params)
              env[:input] = data
              env['CONTENT_LENGTH'] ||= data.length.to_s
              env['CONTENT_TYPE'] = "#{multipart_content_type(env)}; boundary=#{MULTIPART_BOUNDARY}"
            else
              # NB: We do not need to set CONTENT_LENGTH here;
              # Rack::ContentLength will determine it automatically.
              env[:input] = params_to_string(params)
            end
          else
            env[:input] = params
          end
        end

        set_cookie(env.delete(:cookie), uri) if env.key?(:cookie)

        Rack::MockRequest.env_for(uri.to_s, env)
      end

      def multipart_content_type(env)
        requested_content_type = env['CONTENT_TYPE']
        return requested_content_type if requested_content_type.start_with?('multipart/')
        'multipart/form-data'
      end
    end
  end
end
# rubocop:enable all
