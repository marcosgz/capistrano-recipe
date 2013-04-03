Capistrano::Configuration.instance(:must_exist).load do
  namespace :thin do
    desc "Thin restart"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run _thin_cmd('restart')
    end

    desc "Thin start"
    task :start, :roles => :app, :except => { :no_release => true } do
      run _thin_cmd('start')
    end

    desc "Thin stop"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run _thin_cmd('stop')
    end

    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:thin_setup_settings)
          set(:recipe_settings) { thin_template_settings }
          put template.render(_thin_template), _thin_remote_path
        else
          puts "[FATAL] - Thin template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _thin_remote_path, _thin_local_path
      end
    end
  end

  def thin_setup_defaults
    HashWithIndifferentAccess.new({
      'chdir'       => fetch(:current_path),
      'timeout'     => fetch(:thin_timeout, 30),
      'servers'     => fetch(:thin_servers, 4),
      'rails_env'   => fetch(:rails_env, 'production')
    })
  end

  def thin_template_settings
    DeepToHash.to_hash thin_setup_defaults.deep_merge(fetch(:thin_setup_settings, {}))
  end

  def _thin_cmd(action)
    "cd #{current_path}; #{_thin_bin} -C #{_thin_current_config_path} #{action}"
  end

  # The wrapped bin to start thin
  # This is necessary if you're using rvm
  def _thin_bin
    fetch(:thin_bin, 'bundle exec thin')
  end

  # The remote location of thin's config file. Used by god to fire it up
  def _thin_current_config_path
    File.join(current_path, 'config', 'thin.yml')
  end

  def _thin_remote_path
    File.join(shared_path, fetch(:thin_remote_path, 'config/thin.yml'))
  end

  def _thin_local_path
    File.join(local_rails_root, fetch(:thin_local_path, 'config/thin.yml'))
  end

  def _thin_template
    fetch(:thin_template, 'thin.yml.erb')
  end

end
