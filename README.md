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

Site setup:

```ruby
set :db_setup_settings, {
  common: {
    host: '127.0.0.1',
    database: 'db_name'
  }
}
```
