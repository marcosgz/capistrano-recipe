Capistrano::Configuration.instance(:must_exist).load do
  namespace :sunspot do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:sunspot_setup_settings)
          set(:recipe_settings) { sunspot_template_settings }
          put template.render(_sunspot_template), _sunspot_remote_file
        else
          puts "[FATAL] - Sunspot template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _sunspot_remote_file, _sunspot_local_file
      end
    end
  end

  def sunspot_setup_defaults
    HashWithIndifferentAccess.new({
      'common'  => {
        'solr' => {
          'hostname'  => fetch(:sunspot_solr_localhost, 'localhost'),
          'port'      => fetch(:sunspot_solr_port, 'WARNING'),
          'log_level' => fetch(:sunspot_solr_log_level, 'WARNING')
        }
      }
    }.reverse_merge(default_rails_environments_hash))
  end

  def sunspot_template_settings
    DeepToHash.to_hash sunspot_setup_defaults.deep_merge(fetch(:sunspot_setup_settings, {}))
  end

  def _sunspot_remote_file
    File.join(shared_path, fetch(:sunspot_remote_file, 'config/sunspot.yml'))
  end

  def _sunspot_local_file
    File.join(local_rails_root, fetch(:sunspot_local_file, 'config/sunspot.yml'))
  end

  def _sunspot_template
    fetch(:sunspot_template, 'sunspot.yml.erb')
  end
end
