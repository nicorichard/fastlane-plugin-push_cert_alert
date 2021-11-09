require 'fastlane/action'
require_relative '../helper/login_helper'
require_relative '../helper/certificate_helper'
require_relative '../helper/slack_helper'

module Fastlane
  module Actions
    class PushCertAlertAction < Action
      def self.run(params)
        Helper::Login.login(params)

        UI.message("Attempting to fetch existing an existing push certificate.")

        existing_certificate = Helper::Certificate.existing_certificate(params)
        remaining_days = existing_certificate ? Helper::Certificate.remaining_days(existing_certificate) : 0

        if existing_certificate and remaining_days > 0
          UI.message("The push notification profile for '#{existing_certificate.owner_name}' is valid for #{remaining_days.round} days")

          if remaining_days < params[:active_days_limit]
            UI.message("The push notification profile is valid for less than the limit of #{params[:active_days_limit]} days")

            params[:expires_soon].call(existing_certificate, remaining_days) if params[:expires_soon]

            Helper::Slack.slack(
              message: "An APNS push certificate expires in #{remaining_days} days",
              certificate: existing_certificate,
              params: params
            ) if not params[:skip_slack]
          end
        else
          if existing_certificate
            UI.message("The push notification profile has expired")
          else
            UI.message("A push notification profile cannot be found")
          end

          params[:expired].call() if params[:expired]

          Helper::PushCertAlertSlackHelper.slack(
            message: "An APNS push certificate has expired or cannot be found",
            params: params
          ) if not params[:skip_slack]
        end
      end

      def self.description
        "Create alerts for APNS push certificates expiration"
      end

      def self.authors
        ["Nico Richard"]
      end

      def self.details
        # Optional:
        "Create alerts for when APNS push certificates have expired, or will expire soon"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :expires_soon,
                                       description: "Block that is called if the profile expires in less than the `active_days_limit`. Called with `certificate, days_remaining`",
                                       optional: true,
                                       type: Proc),
          FastlaneCore::ConfigItem.new(key: :expired,
                                       description: "Block that is called if the profile is expired. Called with empty params",
                                       optional: true,
                                       type: Proc),
          FastlaneCore::ConfigItem.new(key: :active_days_limit,
                                       env_name: "PEM_ACTIVE_DAYS_LIMIT",
                                       description: "If the current certificate is active for less than this number of days, generate a new one",
                                       default_value: 30,
                                       is_string: false,
                                       type: Integer,
                                       verify_block: proc do |value|
                                         UI.user_error!("Value of active_days_limit must be a positive integer or left blank") unless value.kind_of?(Integer) && value > 0
                                       end),          
          # Spaceship Certificate Fetching
          FastlaneCore::ConfigItem.new(key: :development,
                                       env_name: "PEM_DEVELOPMENT",
                                       description: "Renew the development push certificate instead of the production one",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :website_push,
                                       env_name: "PEM_WEBSITE_PUSH",
                                       description: "Create a Website Push certificate",
                                       is_string: false,
                                       conflicting_options: [:development],
                                       default_value: false),          
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "PEM_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "PEM_USERNAME",
                                       description: "Your Apple ID Username",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-b",
                                       env_name: "PEM_TEAM_ID",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true,
                                       description: "The ID of your Developer Portal team if you're in multiple teams",
                                       optional: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_TEAM_ID"] = value.to_s
                                       end),
          # Slack
          FastlaneCore::ConfigItem.new(key: :skip_slack,
                                       description: "Skip sending an alert to Slack",
                                       optional: true,
                                       type: Boolean,
                                       default_value: false),          
          FastlaneCore::ConfigItem.new(key: :slack_url,
                                       short_option: "-i",
                                       env_name: "SLACK_URL",
                                       sensitive: true,
                                       description: "Create an Incoming WebHook for your Slack group to post results there",
                                       optional: true,
                                       verify_block: proc do |value|
                                         if !value.to_s.empty? && !value.start_with?("https://")
                                           UI.user_error!("Invalid URL, must start with https://")
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :slack_channel,
                                       short_option: "-e",
                                       env_name: "SCAN_SLACK_CHANNEL",
                                       description: "#channel or @username",
                                       optional: true)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          <<-CODE
            push_cert_alert(
              active_days_limit: 60,
              expires_soon: proc do |cert, days|
                puts "#{days} days to live!"
              end,
              expired: proc do
                puts "UH OH!!! Our push cert may be expired!"
              end
            )
          CODE
        ]
      end      
    end
  end
end
