Capistrano::Configuration.instance(:must_exist).load do
  namespace :tire do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:tire_setup_settings)
          set(:recipe_settings) { tire_template_settings }
          put template.render(_tire_template), _tire_remote_file
        else
          puts "[FATAL] - Tire template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _tire_remote_file, _tire_local_file
      end
    end
  end

  def tire_setup_defaults
    HashWithIndifferentAccess.new({
      'common'=>{
        'url' => 'http://localhost:9200'
      }
    }.reverse_merge(default_rails_environments_hash))
  end

  def tire_template_settings
    DeepToHash.to_hash tire_setup_defaults.deep_merge(fetch(:tire_setup_settings, {}))
  end

  def _tire_remote_file
    File.join(shared_path, fetch(:tire_remote_file, 'config/tire.yml'))
  end

  def _tire_local_file
    File.join(local_rails_root, fetch(:tire_local_file, 'config/tire.yml'))
  end

  def _tire_template
    fetch(:tire_template, 'tire.yml.erb')
  end
end
