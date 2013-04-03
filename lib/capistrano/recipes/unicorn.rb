Capistrano::Configuration.instance(:must_exist).load do
  namespace :unicorn do
    desc "Starts unicorn directly"
    task :start, :roles => :app, :except => { :no_release => true } do
      run unicorn_start_cmd
    end

    desc "Stops unicorn directly"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run unicorn_kill_cmd('QUIT')
    end

    desc "Restarts unicorn directly"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run unicorn_kill_cmd('USR2')
    end

    # Required attributes
    # ===================
    # *port* 80
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:unicorn_setup_settings)
          set(:recipe_settings) { unicorn_template_settings }
          put template.render(_unicorn_template), _unicorn_shared_file
        else
          puts "[FATAL] - Unicorn template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _unicorn_shared_file, _unicorn_local_file
      end
    end

    namespace :monit do
      namespace :setup do
        desc "Upload configs"
        task :default, :roles => :app do
          if exists?(:unicorn_setup_settings)
            run "mkdir -p #{_monit_root}"
            set(:recipe_settings) { unicorn_template_settings }
            put template.render(_unicorn_monit_template), _monit_remote_file
          else
            puts "[FATAL] - Unicorn/Monit template settings were not found"
            abort
          end
        end

        desc "Download configs"
        task :get, :roles => :db do
          download _monit_remote_file, File.join(local_rails_root, "config/#{application}-monit")
        end
      end

    end
  end

  def unicorn_setup_defaults
    HashWithIndifferentAccess.new({
      # Number of workers (Rule of thumb is 2 per CPU)
      # Just be aware that every worker needs to cache all classes and thus eat some
      # of your RAM.
      'workers'          => fetch(:unicorn_workers, 4),
      # Workers timeout in the amount of seconds below, when the master kills it and
      # forks another one.
      'workers_timeout'  => fetch(:unicorn_workers_timeout, 30),
      # Workers are started with this user/group
      # By default we get the user/group set in capistrano.
      'user'              => fetch(:unicorn_user) { fetch_user },
      'group'             => fetch(:unicorn_group) { fetch_group },
      'rails_env'         => fetch(:rails_env, 'production'),
      # configs for the monit template
      'pids_root'         => _unicorn_pids_root,
      'application'       => fetch(:application),
      'current_path'      => current_path,
      'remote_config'     => _unicorn_current_file
    })
  end

  def unicorn_template_settings
    DeepToHash.to_hash unicorn_setup_defaults.deep_merge(fetch(:unicorn_setup_settings, {}))
  end

  def unicorn_start_cmd
    "cd #{current_path} && #{_unicorn_bin} -c #{_unicorn_current_file} -E #{rails_env} -D"
  end

  def unicorn_kill_cmd(arg)
    "kill -#{arg} `cat #{_unicorn_pid}`"
  end

  # The wrapped bin to start unicorn
  # This is necessary if you're using rvm
  def _unicorn_bin
    fetch(:unicorn_bin, 'bundle exec unicorn')
  end

  # Defines where the unicorn pid will live.
  def _unicorn_pid
    fetch(:unicorn_pid) { File.join(shared_path, "pids", "unicorn.pid") }
  end

  def _unicorn_pids_root
    _unicorn_pid.split('/').tap{|x| x.pop }.join('/')
  end

  # The remote location of unicorn's config file. Used by god to fire it up
  def _unicorn_current_file
    File.join(current_path, fetch(:unicorn_remote_file, 'config/unicorn.rb'))
  end

  def _unicorn_shared_file
    File.join(shared_path, fetch(:unicorn_remote_file, 'config/unicorn.rb'))
  end

  def _unicorn_local_file
    File.join(local_rails_root, fetch(:unicorn_local_file, 'config/unicorn.rb'))
  end

  def _unicorn_template
    fetch(:unicorn_template, 'unicorn.rb.erb')
  end

  def _unicorn_monit_template
    fetch(:unicorn_monit_template, 'unicorn_monit.erb')
  end

  def _monit_root
    fetch(:monit_root) { "/home/#{fetch_user}/monit" }
  end

  def _monit_remote_file
    File.join(_monit_root, application)
  end

end
