# Example
# =======
#
# gateways_setup_settings:
#   example1:
#     login: 'username'
#     password: 'secret'

Capistrano::Configuration.instance(:must_exist).load do
  set(:gateways_remote_file) { File.join(shared_path, 'config/gateways.yml') } unless exists?(:gateways_remote_file)
  set(:gateways_template, 'gateways.yml.erb') unless exists?(:gateways_template)


  # Required attributes
  # ===================
  # *gateways_name* prod_db
  namespace :gateways do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :db do
        if exists?(:gateways_setup_settings)
          set(:recipe_settings) { fetch(:gateways_setup_settings, {}) }
          put template.render(fetch(:gateways_template)), fetch(:gateways_remote_file)
        else
          puts "[FATAL] - Gateway template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:gateways_remote_file), File.join(local_rails_root, 'config/gateways.yml')
      end
    end
  end
end
