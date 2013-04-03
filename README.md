# capistrano-recipe

Under development

```ruby
require 'capistrano/recipe'
```

### Required configs
```ruby
set :user, 'admin'
set :group, 'admin'
```

### Database
```ruby
set :db_setup_settings, {
  common: {
    host: '127.0.0.1',
    database: 'db_name'
  }
}
```

### Gateways
```ruby
set :gateways_setup_settings, {
  example: {
    username: 'foo',
    password: 'bar'
  }
}
```

### Mailers
```ruby
set :mailer_setup_settings, {
  user_name: "email@example.com",
  password: "secret"
}
```

### Newrelic
```ruby
set :newrelic_setup_settings, {
  common: {
    app_name: 'AppName',
    license_key: 'secret'
  },
  staging: {
    app_name: 'AppName (Staging)'
  }
}
```
