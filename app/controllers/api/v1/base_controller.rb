module Api
  module V1
    class BaseController < ApplicationController
      protected

      # Parses the access token from the header
      def organization
        token = params[:access_token]
        unless token.present?
          bearer = request.headers["HTTP_AUTHORIZATION"]

          # allows our tests to pass
          bearer ||= request.headers["rack.session"].try(:[], 'Authorization')

          if bearer.present?
            token = bearer.split.last
          end
        end

        if token.present?
          api_key = ApiKey.active.where(access_token: token).first
          if api_key
            return api_key.organization
          end
        else
          nil
        end
      end

    end
  end
end