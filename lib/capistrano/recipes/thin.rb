Capistrano::Configuration.instance(:must_exist).load do
  set(:thin_remote_file) { File.join(shared_path, 'config/thin.yml') } unless exists?(:thin_remote_file)
  set(:thin_template, 'thin.yml.erb') unless exists?(:thin_template)


  # The wrapped bin to start thin
  # This is necessary if you're using rvm
  set :thin_bin, 'bundle exec thin' unless exists?(:thin_bin)

  # The remote location of thin's config file. Used by god to fire it up
  set(:thin_remote_config) { File.join(current_path, 'config', 'thin.yml') }

  # task: `thin:setup'
  def thin_template_settings
    fetch(:thin_setup_settings, {}).reverse_merge({
      'chdir'       => fetch(:current_path),
      'timeout'     => fetch(:thin_timeout, 30),
      'servers'     => fetch(:thin_servers, 4),
      'rails_env'   => fetch(:rails_env, 'production')
    })
  end

  def thin_cmd(action)
    "cd #{current_path}; #{thin_bin} -C #{thin_remote_config} #{action}"
  end

  namespace :thin do
    desc "Thin restart"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run thin_cmd('restart')
    end

    desc "Thin start"
    task :start, :roles => :app, :except => { :no_release => true } do
      run thin_cmd('start')
    end

    desc "Thin stop"
    task :stop, :roles => :app, :except => { :no_release => true } do
      run thin_cmd('stop')
    end


    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:thin_setup_settings)
          set(:recipe_settings) { thin_template_settings }
          put template.render(fetch(:thin_template)), fetch(:thin_remote_file)
        else
          puts "[FATAL] - Thin template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:thin_remote_file), File.join(local_rails_root, "config/thin.yml")
      end
    end

  end

end
