# Example
# =======
#
# tire_setup_settings:
#   url: "http://localhost:9200"

Capistrano::Configuration.instance(:must_exist).load do
  set(:tire_remote_file) { File.join(shared_path, 'config/tire.yml') } unless exists?(:tire_remote_file)
  set(:tire_template, 'tire.yml.erb') unless exists?(:tire_template)

  # Required attributes
  # ===================
  # *url* http://localhost:9200
  namespace :tire do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:tire_setup_settings)
          set :recipe_settings, fetch(:tire_setup_settings, {})
          put template.render(fetch(:tire_template)), fetch(:tire_remote_file)
        else
          puts "[FATAL] - Tire template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:tire_remote_file), File.join(local_rails_root, "config/tire.yml")
      end
    end
  end
end
