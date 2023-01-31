
![180100416-b66263e6-1607-4465-b45d-0e298a67c397](https://user-images.githubusercontent.com/68016351/181640742-31ab234a-3b39-432e-b899-21037596b360.png)

Speakeasy is your API Platform team as a service. Use our drop in SDK to manage all your API Operations including embeds for request logs and usage dashboards, test case generation from traffic, and understanding API drift.

The Speakeasy Ruby SDK for evaluating API requests/responses. Compatible with any HTTP framework implemented on top of rack.

## Supported Frameworkds

Tested and supported Frameworks include:

* rails
* sinatra

The Speakeasy Ruby SDK depends only upon Rack, however, so other frameworks should work.

## Installation

Simply install the Speakeasy Ruby SDK gem

```
  gem install speakeasy_ruby_sdk
```

or install using bundler

```
  bundle add speakeasy_ruby_sdk
```

### Minimum configuration

[Sign up for free on our platform](https://www.speakeasyapi.dev/). After you've created a workspace and generated an API key enable Speakeasy in your API as follows:

For a rails project, configure Speakeasy along with your other Middlewares in your `config/application.rb` function:

```ruby
    speakeasy_config = {
      ingestion_server_url: "localhost:443",
      api_key: "YOUR API KEY HERE",
      api_id: "YOUR API ID HERE",
      version_id: "YOUR API VERSION HERE"
    }

    config.middleware.use SpeakeasyRubySdk::Middleware, config
```

Build and deploy your app and that's it. Your API is being tracked in the Speakeasy workspace you just created
and will be visible on the dashboard next time you log in. Visit our [docs site](https://docs.speakeasyapi.dev/) to
learn more.

**warning** Some common middlewares, like `ActionDispatch::Cookies` may rewrite headers in order to provide additional functionality to your app.  In order to capture the original headers, be sure to `use` the Speakeasy middleware before `use`ing any such middlewares.  There is no harm in `use`ing the Speakeasy Ruby Sdk Middleware as your first middleware.

### Tracking Multiple APIs configuration

The Speakeasy SDK is confirgurable using a config parameter. If you want to use the SDK to track multiple Apis or Versions from the same service you can configure individual instances of the SDK, like so:

```ruby
    speakeasy_config_1 = {
      api_key: "YOUR API KEY HERE",
      api_id: "YOUR API ID HERE",
      version_id: "YOUR API VERSION HERE"
    }
    speakeasy_config_2 = {
      api_key: "YOUR API KEY HERE",
      api_id: "YOUR API ID HERE",
      version_id: "YOUR API VERSION HERE"
    }

    config.middleware.use SpeakeasyRubySdk::Middleware, speakeasy_config_1
    config.middleware.use SpeakeasyRubySdk::Middleware, speakeasy_config_2
```

This allows multiple instances of the SDK to be associated with different routers or routes within your service.

### Only Tracking Some Routes

We recommend using the approach native to your framework to limit the application of the Speakeasy middleware.  In Rails, that approach is [Engines](https://guides.rubyonrails.org/engines.html), in Sinatra, middleware are `use`'d by controllers, so add the directive to a Controller which is the parent of those routes you wish to track.

## todo - add Sinatra examples

## Masking sensitive data

Speakeasy can mask sensitive data in the query string parameters, headers, cookies and request/response bodies captured by the SDK. This is useful for maintaining sensitive data isolation, and retaining control over the data that is captured.

Using the Only Tracking Some Routes section above you can completely ignore certain routes, causing the SDK to not selectively capture requests.

But if you would like to be more selective you can mask certain sensitive data using our middleware controller allowing you to mask fields as needed in different handlers:

```
  config = {
    ...
    masking: [
        SpeakeasyRubySdk::MaskConfig.new(:request_header, ['Authorization'])
      ],
  }
```
The `masking` section of the config map takes an array of different masking options

  - `SpeakeasyRubySdk::MaskConfig.new(:query_params, attributes, mask_strings)` will mask the specified query params with the optional string mask
  - `SpeakeasyRubySdk::MaskConfig.new(:request_headers, attributes, mask_strings)` will mask the specified request_headers with the optional string mask
  - `SpeakeasyRubySdk::MaskConfig.new(:response_headers, attributes, mask_strings)` will mask the specified response headers with the optional string mask
  - `SpeakeasyRubySdk::MaskConfig.new(:request_cookies, attributes, mask_strings)` will mask the specified request cookies with the optional string mask
  - `SpeakeasyRubySdk::MaskConfig.new(:response_cookies, attributes, mask_strings)` will mask the specified response cookies with the optional string mask
  - `SpeakeasyRubySdk::MaskConfig.new(:request_body_string, attributes, mask_strings)` specified request body fields with an optional mask. Supports string fields only. Matches using regex.
  - `SpeakeasyRubySdk::MaskConfig.new(:request_body_number, attributes, mask_strings)` specified request body fields with an optional mask. Supports numeric fields only. Matches using regex.
  - `SpeakeasyRubySdk::MaskConfig.new(:response_body_string, attributes, mask_strings)` specified response body fields with an optional mask. Supports string fields only. Matches using regex.
  - `SpeakeasyRubySdk::MaskConfig.new(:response_body_number, attributes, mask_strings)` specified response body fields with an optional mask. Supports numeric fields only. Matches using regex.

In all of the above instances, you may optionally provide an array of mask strings.  If you leave this field out, or pass an empty array, the system will mask with our default mask value "__masked__" (-12321 for numbers).  If you provide an array with a single value, then the system will mask all matches with that value.  If you provide more than one value, then each match will be replaced by the corresponding mask values (if there are too few, then the remaining matches will receive our default mask value).