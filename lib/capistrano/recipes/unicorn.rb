# Example
# =======
#
# unicorn_setup_settings:
#   port: 80
Capistrano::Configuration.instance(:must_exist).load do
  set(:monit_root){ "/home/#{user}/monit/metromix" }

  # The wrapped bin to start unicorn
  # This is necessary if you're using rvm
  set :unicorn_bin, 'bundle exec unicorn' unless exists?(:unicorn_bin)

  # The remote location of unicorn's config file. Used by god to fire it up
  set(:unicorn_remote_config) { "#{current_path}/config/unicorn.rb" }

  set(:unicorn_template, 'unicorn.rb.erb') unless exists?(:unicorn_template)
  set(:unicorn_monit_template, 'unicorn_monit.erb') unless exists?(:unicorn_monit_template)

  # Defines where the unicorn pid will live.
  set(:unicorn_pid) { File.join(shared_path, "pids", "unicorn.pid") } unless exists?(:unicorn_pid)

  # task: `unicorn:setup'
  def unicorn_template_settings
    fetch(:unicorn_setup_settings, {}).reverse_merge({
      # Number of workers (Rule of thumb is 2 per CPU)
      # Just be aware that every worker needs to cache all classes and thus eat some
      # of your RAM.
      'workers'          => fetch(:unicorn_workers, 4),
      # Workers timeout in the amount of seconds below, when the master kills it and
      # forks another one.
      'workers_timeout'  => fetch(:unicorn_workers_timeout, 30),
      # Workers are started with this user/group
      # By default we get the user/group set in capistrano.
      'user'              => fetch(:unicorn_user) { user },
      'group'             => fetch(:unicorn_group) { group },
      'rails_env'         => fetch(:rails_env, 'production'),
      # configs for the monit template
      'pids_root'         => fetch(:unicorn_pids_root) { File.join(shared_path, "pids") },
      'application'       => fetch(:application),
      'current_path'      => fetch(:current_path),
      'remote_config'     => fetch(:unicorn_remote_config)
    })
  end

  def unicorn_start_cmd
    "cd #{current_path} && #{unicorn_bin} -c #{unicorn_remote_config} -E #{rails_env} -D"
  end

  def unicorn_stop_cmd
    "kill -QUIT `cat #{unicorn_pid}`"
  end

  def unicorn_restart_cmd
    "kill -USR2 `cat #{unicorn_pid}`"
  end

  namespace :unicorn do
    desc "Starts unicorn directly"
    task :start, :roles => :app, :except => { :no_release => true } do
      run unicorn_start_cmd
    end

    desc "Stops unicorn directly"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run unicorn_stop_cmd
    end

    desc "Restarts unicorn directly"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run unicorn_restart_cmd
    end

    # Required attributes
    # ===================
    # *port* 80
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :db do
        if exists?(:unicorn_setup_settings)
          set(:recipe_settings) { unicorn_template_settings }
          put template.render(fetch(:unicorn_template)), File.join(shared_path, 'config/unicorn.rb')
        else
          puts "[FATAL] - Unicorn template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download File.join(shared_path, 'config/unicorn.rb'), File.join(local_rails_root, "config/unicorn.rb")
      end
    end

    namespace :monit do
      namespace :setup do
        desc "Upload configs"
        task :default, :roles => :db do
          if exists?(:unicorn_setup_settings)
            run "mkdir -p #{monit_root}"
            set(:recipe_settings) { unicorn_template_settings }
            put template.render(fetch(:unicorn_monit_template)), File.join(monit_root, application)
          else
            puts "[FATAL] - Unicorn/Monit template settings were not found"
            abort
          end
        end

        desc "Download configs"
        task :get, :roles => :db do
          download File.join(monit_root, application), File.join(local_rails_root, "config/#{application}-monit")
        end
      end

    end
  end
end
