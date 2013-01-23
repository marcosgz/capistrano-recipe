# Example
# =======
#
# passenger_setup_settings:
#   port: 80
#   auth_user_file: '/path/to/htpasswd'

Capistrano::Configuration.instance(:must_exist).load do

  set(:apache_sites_available) { "/home/#{user}/configs/apache/sites-available" }
  set(:apache_sites_enabled) { "/home/#{user}/configs/apache/sites-enabled" }
  set(:apache_remote_file) { File.join(apache_sites_available, "#{application}.conf") } unless exists?(:apache_remote_file)
  set(:apache_template, 'passenger.conf.erb') unless exists?(:apache_template)

  # task: `passenger:setup'
  def passenger_template_settings
    fetch(:passenger_setup_settings, {}).reverse_merge({
      'server_name'       => fetch(:domain),
      'document_root'     => File.join(fetch(:current_path), 'public'),
      'rails_env'         => fetch(:rails_env, 'production')
    })
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
      run "rm #{apache_sites_available}/#{application}.conf"
    end

    desc "Disable passenger config"
    task :disable, :roles => :app, :except => { :no_release => true } do
      run "rm #{apache_sites_enabled}/#{application}.conf"
    end


    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :db do
        if exists?(:passenger_setup_settings)
          run "mkdir -p #{apache_sites_available} #{apache_sites_enabled}"
          set(:recipe_settings) { passenger_template_settings }
          put template.render(fetch(:apache_template)), fetch(:apache_remote_file)
        else
          puts "[FATAL] - Passenger template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:apache_remote_file), File.join(local_rails_root, "configs/#{application}.conf")
      end
    end

  end
end
