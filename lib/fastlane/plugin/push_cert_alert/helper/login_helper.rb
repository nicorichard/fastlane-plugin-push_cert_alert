require 'spaceship'

module Fastlane
    module Helper
      class Login
        def self.login(params)
          UI.message("Starting login with user '#{params[:username]}'")
          Spaceship.login(params[:username], nil)
          Spaceship.client.select_team
          UI.message("Successfully logged in")
        end
      end
    end
end