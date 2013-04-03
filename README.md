# capistrano-recipe

Under development

```ruby
require 'capistrano/recipe'
```

### Required configs
```ruby
set :user, 'admin'
set :group, 'admin'
set :domain, 'www.example.com'
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

### Passenger
```ruby
set :passenger_setup_settings, {
  port: 80
}
```

### Settler
```ruby
set :settler_setup_settings, {
  name: 'String Text',      # "name"        =>  {"alt"=>"name", "value"=>"String Text"}
  price: 100.0,             # "price"       =>  {"alt"=>"price", "value"=>"100.0", "typecast"=>"float"}
  views: 9,                 # "views"       =>  {"alt"=>"views", "value"=>"9", "typecast"=>"integer"}
  approved: true,           # "approved"    =>  {"alt"=>"approved", "value"=>"true", "typecast"=>"boolean"}
  deleted: false,           # "deleted"     =>  {"alt"=>"deleted", "value"=>"false", "typecast"=>"boolean"}
  published_at: Time.now,   # "published_at"=>  {"alt"=>"published_at", "value"=>"2013-04-03 16:25:26 -0300", "typecast"=>"datetime"}
  password: {               # "password"    =>  {"alt"=>"Password", "value"=>"secret", "typecast"=>"password"}
    alt: 'Password',
    value: 'secret',
    typecast: 'password'
  }
}

```

### Shards
```ruby
set :shards_setup_settings, {
  databases: {
    production:{
      slave1: {}
    }
  }
}
```

### Thin
```ruby
set :thin_setup_settings, {
  port: 80
}
```
