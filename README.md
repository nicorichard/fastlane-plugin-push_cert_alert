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

> If you already use get_push_certificate (pem) and slack actions somewhere in your lanes then you are already configured.\
> Run `bundle exec fastlane action push_cert_alert` for more information.

Simply add `push_cert_alert` to some lane:

```ruby
lane :test do
    push_cert_alert
end
```

And you will receive a Slack alert when your cert has expired (or expires soon):

> An APNS push certificate expires in 30 days
>
> **Lane:** test\
> **Result:** Error\
> **App Identifier:** com.company.name\
> **Type:**  production\
> **Expires at:** 1955-11-05 11:11:11 UTC\
> **Name:** Apple Push Services

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

## Integration

Integrate this lane with your other lanes and/or CI to be made aware early of any upcoming push certificate expiration.

### Circle CI

Example Circle CI job which could be run with your daily builds

```yaml

jobs:
  push_cert_alert:
    executor: my_executor
    steps:
      - checkout
      - restore_cache
      - install_bundles
      - run: bundle exec fastlane push_cert_alert

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
