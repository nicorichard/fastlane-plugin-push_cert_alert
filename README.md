# push_cert_alert plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-push_cert_alert)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-push_cert_alert`, add it to your project by running:

```bash
fastlane add_plugin push_cert_alert
```

## About push_cert_alert

Generate alerts for when a push certificate will expire soon, or has expired already.

## Usage

If you already use pem/get_push_certificate, and slack actions somewhere in your lanes then most things will already be configured. Just run `push_cert_alert` from a lane to receive Slack notifications when approaching your APNS profile's expiration date.

You can also add custom callbacks for the events if desired:

```ruby
push_cert_alert(
    active_days_limit: 60, # Default is 30
    skip_slack: true, # Defaults to true
    expires_soon: proc do |cert, days|
        puts "#{days} days until #{cert.name} expires. Perhaps you should run `get_push_certificate` soon to upgrade your push services."
    end,
    expired: proc do
        puts "🚨 DANGER - Our push cert is expired (or missing)!"
    end
)
```

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
