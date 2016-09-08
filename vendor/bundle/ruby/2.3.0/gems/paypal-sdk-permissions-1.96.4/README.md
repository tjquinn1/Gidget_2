# Permissions SDK

The PayPal Permission SDK provides Ruby APIs for developers to request and obtain permissions from merchants and consumers, to execute APIs on behalf of them. The permissions include variety of operations from processing payments to accessing account transaction history.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paypal-sdk-permissions'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install paypal-sdk-permissions
```

## Configuration

For Rails application:

```sh
rails g paypal:sdk:install
```

For other ruby application, create a configuration file(`config/paypal.yml`):

```yaml
development: &default
  username: jb-us-seller_api1.paypal.com
  password: WX4WTU3S8MY44S7F
  signature: AFcWxV21C7fd0v3bYYYRCpSSRl31A7yDhhsPUU2XhtMoZXsWHFxu-RWy
  app_id: APP-80W284485P519543T
  http_timeout: 30
  mode: sandbox
  # # with certificate
  # cert_path: "config/cert_key.pem"
  # # with token authentication
  # token: ESTy2hio5WJQo1iixkH29I53RJxaS0Gvno1A6.YQXZgktxbY4I2Tdg
  # token_secret: ZKPhUYuwJwYsfWdzorozWO2U9pI
  # # with Proxy
  # http_proxy: http://proxy-ipaddress:3129/
  # # with device ip address
  # device_ipaddress: "127.0.0.1"
test:
  <<: *default
production:
  <<: *default
  mode: live
```

Load Configurations from specified file:

```ruby
PayPal::SDK::Core::Config.load('config/paypal.yml',  ENV['RACK_ENV'] || 'development')
```

## Example

Request permission:

```ruby
require 'paypal-sdk-permissions'

PayPal::SDK.configure({
  :mode      => "sandbox",  # Set "live" for production
  :app_id    => "APP-80W284485P519543T",
  :username  => "jb-us-seller_api1.paypal.com",
  :password  => "WX4WTU3S8MY44S7F",
  :signature => "AFcWxV21C7fd0v3bYYYRCpSSRl31A7yDhhsPUU2XhtMoZXsWHFxu-RWy" })

@api = PayPal::SDK::Permissions::API.new

# Build request object
@request_permissions = @api.build_request_permissions({
  :scope => ["ACCESS_BASIC_PERSONAL_DATA","ACCESS_ADVANCED_PERSONAL_DATA"],
  :callback => "http://localhost:3000/samples/permissions/get_access_token" })

# Make API call & get response
@response = @api.request_permissions(@request_permissions)

# Access Response
if @response.success?
  @response.token
  @api.grant_permission_url(@response) # Redirect url to grant permissions
else
  @response.error
end
```

Make API call with `token` and `token_secret`:

```ruby
@api = PayPal::SDK::Permissions::API.new({
   :token => "3rMSi3kCmK1Q3.BKxkH29I53R0TRLrSuCO..l8AMOAFM6cQhPTTrfQ",
   :token_secret => "RuE1j8RNRlSuL5T-PSSpVWLvOlI" })

@response = @api.get_basic_personal_data({
  :attributeList => {
    :attribute => [ "http://axschema.org/namePerson/first" ] } })
```


For more samples [https://paypal-sdk-samples.herokuapp.com/permissions/](https://paypal-sdk-samples.herokuapp.com/permissions/)

## Samples App

Add following line in rails `Gemfile`:

```ruby
gem 'paypal-sdk-permissions'
gem 'permissions_samples', :git => "https://github.com/paypal/permissions-sdk-ruby.git", :group => :development
```

Configure routes(`config/routes.rb`):

```ruby
mount PermissionsSamples::Engine => "/samples" if Rails.env.development?
```

To get default paypal configuration execute:

```sh
rails g paypal:sdk:install
```

Run `rails server` and check the samples.
