# Example
# =======
#
# db_setup_settings:
#   common:
#     host: 127.0.0.1
#     database: db_name

Capistrano::Configuration.instance(:must_exist).load do
  # Required attributes
  # ===================
  # *database_name* prod_db
  namespace :db do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:db_setup_settings)
          set(:recipe_settings, database_template_settings)
          put template.render(_database_template), _database_remote_path
        else
          puts "[FATAL] - Database template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _database_remote_path, _database_local_path
      end
    end
  end

  def database_setup_defaults
    HashWithIndifferentAccess.new({
      'common'      => {
        'adapter'   => fetch(:database_adapter, 'mysql2'),
        'encoding'  => fetch(:database_encoding, 'utf8'),
        'reconnect' => fetch(:database_reconnect, false),
        'username'  => fetch(:database_username) { user },
        'password'  => self[:database_password],
        'host'      => fetch(:database_host, '127.0.1.1')
      },
      'development' => {},
      'production'  => {},
      'test'        => {}
    })
  end

  def database_template_settings
    database_setup_defaults.deep_merge(HashWithIndifferentAccess.new(fetch(:db_setup_settings, {})))
  end

  def _database_remote_path
    fetch(:database_remote_path, File.join(shared_path, 'config/database.yml') )
  end

  def _database_local_path
    fetch(:database_local_path, File.join(local_rails_root, 'config/database.yml') )
  end

  def _database_template
    fetch(:database_template, 'database.yml.erb')
  end

end
