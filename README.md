# BackAsswards

This gem provides robust deprecation options. You can mark blocks of code to give deprecation warnings immediately or when future versions release. Or both!

For example, the TOS on one API I maintain guarantees backward compatibility for 3 versions for 3 client applications. Keeping up with this is a nightmare. With BackAsswards I can specify a block of code to notify me when it is safe to remove.

## Installation

Add this line to your application's Gemfile:

    gem 'back_asswards'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install back_asswards

## Usage

In your code just wrap a block that you want to deprecate:

```
deprecate("1.5.5") do
  super_hacky_function_that_needs_to_go_away
end
```

You can also scope your versions to different sets. For example, if you need code to support an Android app and an iOS app, and you want to know when it's safe to remove for both:

```
deprecate(android: "1.5.5", ios: "1.2.3") do
  accept_old_params
end
```

BackAsswards will only throw a deprecation error when both android and ios have reached sufficient versions. This is what will go into your log:

```
DEPRECATION WARNING: Version android 2.3.5 ["../app/controllers/api/v1/users_controller.rb", 75]
DEPRECATION WARNING: Version ios 1.6.0 ["../app/controllers/api/v1/users_controller.rb", 75]
DEPRECATED CODE: [[:ios, "2.3.5"], [:android, "1.6.0"]] ["../app/controllers/api/v1/users/orders_controller.rb", 75]
```

It will also fire a notification to Airbrake if you set it up in the config.

## Configuration

Using an Array:
```
BackAsswards.configure({
  data: ["2.3.6", "2.3.7", "2.3.8", "2.3.5"],
  version_field: "version",
  scope_field: nil,
  data_storage: "Array",
  num_versions_to_allow: 3,
  warn: true, # setting this will do a traditional DEPRECATION WARNING
  use_airbrake: true, # Will send a notification to Airbrake when the code is ready to be obliterated.
  logger: Rails.logger # you can set this to the logger of your choosing. default is STDOUT
})
```

Using a scoped Hash:
```
BackAsswards.configure({
  data: {
    android: ["2.3.6", "2.3.7", "2.3.8", "2.3.5"],
    ios: ["1.2.3", "1.2.4"]
  },
  version_field: "version",
  scope_field: nil,
  data_storage: "Hash",
  num_versions_to_allow: 3
})
```

WIP: Keep your versions in a database? Good.
```
BackAsswards.configure({
  data: "Version",
  version_field: "version",
  scope_field: "client_type",
  data_storage: "ActiveRecord",
  num_versions_to_allow: 3
})
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
