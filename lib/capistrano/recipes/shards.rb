Capistrano::Configuration.instance(:must_exist).load do
  namespace :shards do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:shards_setup_settings)
          set(:recipe_settings) do
            {
              'main' => database_template_settings,
              'shards' => shards_template_settings
            }
          end
          put template.render(_shards_template), _shards_remote_path
        else
          puts "[FATAL] - Shards template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _shards_remote_path, _shards_local_path
      end
    end

  end

  def shards_setup_defaults
    HashWithIndifferentAccess.new({
      'environments'      => %w(production),
      'databases'         => {}
    })
  end

  def shards_template_settings
    DeepToHash.to_hash shards_setup_defaults.deep_merge(fetch(:shards_setup_settings, {}))
  end

  def _shards_remote_path
    File.join(shared_path, fetch(:shards_remote_path, 'config/shards.yml'))
  end

  def _shards_local_path
    File.join(local_rails_root, fetch(:shards_local_path, 'config/shards.yml'))
  end

  def _shards_template
    fetch(:shards_template, 'shards.yml.erb')
  end
end
