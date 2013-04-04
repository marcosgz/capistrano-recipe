Capistrano::Configuration.instance(:must_exist).load do
  namespace :resque do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:resque_setup_settings)
          set(:recipe_settings) { resque_template_settings }
          put template.render(_resque_template), _resque_remote_file
        else
          puts "[FATAL] - Resque template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _resque_remote_file, _resque_local_file
      end
    end
  end

  def resque_setup_defaults
    HashWithIndifferentAccess.new(default_rails_environments.inject({}){|r, v|
      r.merge Hash[v, 'localhost:6379']
    })
  end

  def resque_template_settings
    DeepToHash.to_hash resque_setup_defaults.deep_merge(fetch(:resque_setup_settings, {}))
  end

  def _resque_remote_file
    File.join(shared_path, fetch(:resque_remote_file, 'config/resque.yml'))
  end

  def _resque_local_file
    File.join(local_rails_root, fetch(:resque_local_file, 'config/resque.yml'))
  end

  def _resque_template
    fetch(:resque_template, 'resque.yml.erb')
  end
end
