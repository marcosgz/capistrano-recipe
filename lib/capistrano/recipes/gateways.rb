Capistrano::Configuration.instance(:must_exist).load do

  namespace :gateways do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:gateways_setup_settings)
          set(:recipe_settings) { HashWithIndifferentAccess.new(fetch(:gateways_setup_settings, {})) }
          put template.render(_gateways_template), _gateways_remote_file
        else
          puts "[FATAL] - Gateways template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _gateways_remote_file, _gateways_local_file
      end
    end
  end

  def _gateways_remote_file
    File.join(shared_path, fetch(:gateways_remote_file, 'config/gateways.yml'))
  end

  def _gateways_local_file
    File.join(local_rails_root, fetch(:gateways_local_file, 'config/gateways.yml'))
  end

  def _gateways_template
    fetch(:gateways_template, 'gateways.yml.erb')
  end
end
