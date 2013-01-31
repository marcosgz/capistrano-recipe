# Example
# =======
#
# passenger_setup_settings:
#   port: 80
#   auth_user_file: '/path/to/htpasswd'

Capistrano::Configuration.instance(:must_exist).load do

  # task: `passenger:setup'
  def passenger_template_settings
    fetch(:passenger_setup_settings, {}).reverse_merge({
      'sites_available'   => fetch(:apache_sites_available, "/home/#{user}/configs/apache/sites-available"),
      'sites_enabled'     => fetch(:apache_sites_enabled, "/home/#{user}/configs/apache/sites-enabled"),
      'vhost_filename'    => fetch(:apache_vhost_filename) { "#{application}.conf" },
      'template_filename' => fetch(:apache_template_filename) { 'passenger.conf.erb' },
      'server_name'       => fetch(:domain),
      'document_root'     => File.join(fetch(:current_path), 'public'),
      'rails_env'         => fetch(:rails_env, 'production')
    })
  end

  def apache_available_vhost
    File.join(*passenger_template_settings.slice('sites_available', 'vhost_filename').values)
  end

  def apache_enabled_vhost
    File.join(*passenger_template_settings.slice('sites_enabled', 'vhost_filename').values)
  end

  namespace :passenger do
    desc "Restart Rails app running under Phusion Passenger by touching restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end

    desc "Inspect Phusion Passenger's memory usage."
    task :memory, :roles => :app do
      run "sudo passenger-memory-stats"
    end

    desc "Inspect Phusion Passenger's internal status."
    task :status, :roles => :app do
      run "sudo passenger-status"
    end

    desc "Remove passenger config"
    task :remove, :roles => :app, :except => { :no_release => true } do
      passenger.disable
      run "rm #{apache_available_vhost}"
    end

    desc "Disable passenger config"
    task :disable, :roles => :app, :except => { :no_release => true } do
      run "rm #{apache_enabled_vhost}"
    end

    desc "Enable passenger config"
    task :enable, :roles => :app, :except => { :no_release => true } do
      run "ln -nsf #{apache_available_vhost} #{apache_enabled_vhost}"
    end

    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :db do
        if exists?(:passenger_setup_settings)
          run "mkdir -p #{ passenger_template_settings.slice('sites_available', 'sites_enabled').map{|k,v| v}.join(' ') }"
          set(:recipe_settings) { passenger_template_settings }
          put template.render( passenger_template_settings['template_filename'] ), apache_available_vhost
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
end
