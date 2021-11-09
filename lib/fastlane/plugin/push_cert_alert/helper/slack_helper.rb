require 'fastlane/action'
require 'fastlane/actions/slack'
require 'fastlane_core/configuration/configuration'

module Fastlane
  module Helper
    class Slack
      def self.slack(message: "", certificate: nil, params: {})
        fields = [
          {
            title: "App Identifier",
            value: params[:app_identifier],
            short: true
          },
          {
            title: "Type",
            value: Helper::Certificate.certificate_type(params),
            short: true
          }
        ]

        if certificate
          fields << {
            title: "Expires at",
            value: certificate.expires,
            short: true
          }

          fields << {
            title: "Name",
            value: certificate.name,
            short: true
          }
        end

        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          message: message,
          channel: params[:slack_channel],
          slack_url: params[:slack_url],
          success: false,
          payload: {},
          attachment_properties: {
            fields: fields
          }
        })

        Fastlane::Actions::SlackAction.run(options)
      end
    end
  end
end
