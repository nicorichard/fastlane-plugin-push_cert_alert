require 'spaceship'

module Fastlane
    module Helper
        class Certificate
            def self.certificate(params)
              if params[:development]
                Spaceship.certificate.development_push
              elsif params[:website_push]
                Spaceship.certificate.website_push
              else
                Spaceship.certificate.production_push
              end
            end
      
            def self.certificate_type(params)
              if params[:development]
                'development'
              elsif params[:website_push]
                'website'
              else
                'production'
              end
            end      
      
            def self.certificate_sorted(params)
              certificate(params).all.sort { |x, y| y.expires <=> x.expires }
            end
      
            def self.existing_certificate(params)
              certificate_sorted(params).detect do |c|
                c.owner_name == params[:app_identifier]
              end
            end
      
            def self.remaining_days(certificate)
              ((certificate.expires - Time.now) / 60 / 60 / 24).round(2)
            end
        end
    end
end