# Example
# =======
#
# shards_setup_settings:
#   databases:
#     production:
#       slave1: {}
Capistrano::Configuration.instance(:must_exist).load do
  set(:shards_remote_file) { File.join(shared_path, 'config/shards.yml') } unless exists?(:shards_remote_file)
  set(:shards_template, 'shards.yml.erb') unless exists?(:shards_template)

  def shards_setup_defaults
    {
      'replicated'        => true,
      'verify_connection' => true,
      'environments'      => %w(production),
      'databases'         => {}
    }
  end

  # task: `shards:setup'
  def shards_template_settings
    fetch(:shards_setup_settings, {}).reverse_merge(shards_setup_defaults)
  end

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
          put template.render(fetch(:shards_template)), fetch(:shards_remote_file)
        else
          puts "[FATAL] - Shards template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:shards_remote_file), File.join(local_rails_root, "config/shards.yml")
      end
    end

  end
end
