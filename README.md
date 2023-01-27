
![180100416-b66263e6-1607-4465-b45d-0e298a67c397](https://user-images.githubusercontent.com/68016351/181640742-31ab234a-3b39-432e-b899-21037596b360.png)

Speakeasy is your API Platform team as a service. Use our drop in SDK to manage all your API Operations including embeds for request logs and usage dashboards, test case generation from traffic, and understanding API drift.

The Speakeasy Ruby SDK for evaluating API requests/responses. Compatible with any HTTP framework implemented on top of rack.

## Supported Frameworkds

Tested and supported Frameworks include:

* rails
* sinatra

However, the Speakeasy Ruby SDK depends only upon Rack, so other frameworks should work.

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

### Advanced configuration

The Speakeasy SDK is confirgurable using a config parameter. If you want to use the SDK to track multiple Apis or Versions from the same service you can configure individual instances of the SDK, like so:

```ruby
    speakeasy_config = {
      ingestion_server_url: "localhost:443",
      api_key: "YOUR API KEY HERE",
      api_id: "YOUR API ID HERE",
      version_id: "YOUR API VERSION HERE"
    }

    config.middleware.use SpeakeasyRubySdk::Middleware, config
```

This allows multiple instances of the SDK to be associated with different routers or routes within your service.