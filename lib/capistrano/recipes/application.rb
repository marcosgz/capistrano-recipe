Capistrano::Configuration.instance(:must_exist).load do

  set :app_setup_defaults, %w(app:create:dirs app:create:application_server db:setup)

  namespace :app do
    task :setup, :roles => :app do
      (fetch(:app_setup_defaults)+_app_setup_aditional).each do |name|
        if (t=top.find_task(name))
          execute_task(t)
        end
      end
    end


    namespace :create do
      task :dirs, :roles => :app do
        deploy.setup
        commands = %w(config sockets uploads backup bundle pids tmp/cache public/cache).map do |path|
          "if [ ! -d '#{path}' ]; then mkdir -p #{path}; fi;"
        end
        run "cd #{shared_path}; #{commands.join(' ')}"
        run "chmod 777 #{shared_path}/public/cache #{shared_path}/tmp/cache"
      end


      task :application_server, :roles => :app do
        # App Server
        case fetch(:app_server_name, nil).to_s
        when 'passenger'
          passenger.setup
        when 'unicorn'
          unicorn.setup
          unicorn.monit.setup
        when 'thin'
          thin.setup
        else
          puts "WARNING: set :app_server_name with (passenger, unicorn or thin) to automatically run the <server>:setup task"
        end
      end
    end


    namespace :destroy do
      desc "Remove application directory"
      task :all, :roles => :app do
        set(:confirmed) do
          puts <<-WARN

          ========================================================================

            WARNING: You're about to remove the application directory:
            "#{ deploy_to }"

          ========================================================================

          WARN
          answer = Capistrano::CLI.ui.ask "  Are you sure you want to continue? (Yn) "
          if answer == 'Y' then true else false end
        end

        if fetch(:confirmed)
          passenger.remove
          run "rm -Rf #{deploy_to}"
        else
          abort
        end

      end
    end

  end

  def _app_setup_aditional
    fetch(:app_setup_aditional, [])
  end

  def fetch_user
    fetch(:user, 'app')
  end

  def fetch_group
    fetch(:group, 'app')
  end

  def default_rails_environments_hash
    default_rails_environments.inject({}){|r, v| r.merge Hash[v, {}] }
  end

  def default_rails_environments
    fetch(:rails_environments, %w(production development staging test))
  end
end
