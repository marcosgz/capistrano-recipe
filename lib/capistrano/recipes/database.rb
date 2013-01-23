# Example
# =======
#
# db_setup_settings:
#   common:
#     host: 127.0.0.1
#     database: db_name

Capistrano::Configuration.instance(:must_exist).load do
  set(:database_remote_file) { File.join(shared_path, 'config/database.yml') } unless exists?(:database_remote_file)
  set(:database_template, 'database.yml.erb') unless exists?(:database_template)

  def database_setup_defaults
    {
      'common'      => {
        'adapter'   => fetch(:database_adapter, 'mysql2'),
        'encoding'  => fetch(:database_encoding, 'utf8'),
        'reconnect' => fetch(:database_reconnect, false),
        'pool'      => fetch(:database_pool, 2),
        'username'  => fetch(:database_username) { user },
        'password'  => self[:database_password],
        'host'      => self[:database_host]
      },
      'development' => {},
      'staging'     => {},
      'production'  => {},
      'test'        => {}
    }
  end

  # task: `database:setup'
  def database_template_settings
    fetch(:db_setup_settings, {}).reverse_merge(
      database_setup_defaults.keys.inject({}) {|r, e| r.merge Hash[e, Hash.new] }
    ).inject({}) do |r, (k,v)|
      r.merge Hash[k, v.reverse_merge(database_setup_defaults[k] || {})]
    end
  end

  # Required attributes
  # ===================
  # *database_name* prod_db
  namespace :db do

    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :db do
        if exists?(:db_setup_settings)
          set(:recipe_settings, database_template_settings)
          put template.render(fetch(:database_template)), fetch(:database_remote_file)
        else
          puts "[FATAL] - Database template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:database_remote_file), File.join(local_rails_root, 'config/database.yml')
      end
    end

  end
end
