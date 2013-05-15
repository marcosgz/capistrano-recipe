Capistrano::Configuration.instance(:must_exist).load do

  namespace :passenger do
    desc "Restart Rails app running under Phusion Passenger by touching restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end

    desc "Inspect Phusion Passenger's memory usage."
    task :memory, :roles => :app do
      run "#{try_sudo} passenger-memory-stats"
    end

    desc "Inspect Phusion Passenger's internal status."
    task :status, :roles => :app do
      run "#{try_sudo} passenger-status"
    end

    desc "Remove passenger config"
    task :remove, :roles => :app, :except => { :no_release => true } do
      passenger.disable
      run "if [ -e #{_passenger_available_vhost} ]; then rm #{_passenger_available_vhost}; fi"
    end

    desc "Disable passenger config"
    task :disable, :roles => :app, :except => { :no_release => true } do
      run "if [ -e #{_passenger_enabled_vhost} ]; then rm #{_passenger_enabled_vhost}; fi"
    end

    desc "Enable passenger config"
    task :enable, :roles => :app, :except => { :no_release => true } do
      run "ln -nsf #{_passenger_available_vhost} #{_passenger_enabled_vhost}"
    end

    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:passenger_setup_settings)
          run "mkdir -p #{_passenger_sites_available} #{_passenger_sites_enabled}"
          set(:recipe_settings) { passenger_template_settings }
          put template.render(_passenger_template), _passenger_available_vhost
          passenger.enable
        else
          puts "[FATAL] - Passenger template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download apache_available_vhost, File.join(local_rails_root, "config/#{application}.conf")
      end
    end

  end

  def passenger_setup_defaults
    HashWithIndifferentAccess.new({
      'server_name'       => fetch(:domain),
      'document_root'     => File.join(current_path, 'public'),
      'rails_env'         => fetch(:rails_env, 'production')
    })
  end

  def passenger_template_settings
    DeepToHash.to_hash passenger_setup_defaults.deep_merge(fetch(:passenger_setup_settings, {}))
  end

  def _passenger_available_vhost
    File.join(_passenger_sites_available, _passenger_vhost_filename)
  end

  def _passenger_enabled_vhost
    File.join(_passenger_sites_enabled, _passenger_vhost_filename)
  end

  def _passenger_vhost_filename
    fetch(:passenger_vhost_filename) { "#{application}.conf" }
  end

  def _passenger_sites_available
    fetch(:passenger_sites_available, "/home/#{fetch_user}/configs/apache/sites-available")
  end

  def _passenger_sites_enabled
    fetch(:passenger_sites_enabled, "/home/#{fetch_user}/configs/apache/sites-enabled")
  end

  def _passenger_template
    fetch(:passenger_template, 'passenger.conf.erb')
  end
end
