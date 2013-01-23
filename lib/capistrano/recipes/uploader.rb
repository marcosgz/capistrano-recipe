# Example
# =======
#
# uploader_setup_settings:
#   fog_credentials:
#     provider: Rackspace
#     rackspace_username: username
#     rackspace_api_key: secret
#   fog_directory: frontend
#   fog_host: http://123.rackcdn.com

Capistrano::Configuration.instance(:must_exist).load do
  set(:uploader_remote_file) { File.join(shared_path, 'config/uploader.yml') } unless exists?(:uploader_remote_file)
  set(:uploader_template, 'uploader.yml.erb') unless exists?(:uploader_template)

  namespace :uploader do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :db do
        if exists?(:uploader_setup_settings)
          set :recipe_settings, fetch(:uploader_setup_settings, {})
          put template.render(fetch(:uploader_template)), fetch(:uploader_remote_file)
        else
          puts "[FATAL] - Uploader template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:uploader_remote_file), File.join(local_rails_root, "config/uploader.yml")
      end
    end

  end
end
