# Example
# =======
#
# mailer_setup_settings:
#   user_name: "email@example.com"
#   password: "secret"

Capistrano::Configuration.instance(:must_exist).load do

  set(:mailer_remote_file) { File.join(shared_path, 'config/mailers.yml') } unless exists?(:mailer_remote_file)
  set(:mailer_template, 'mailers.yml.erb') unless exists?(:mailer_template)

  namespace :mailer do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:mailer_setup_settings)
          set :recipe_settings, fetch(:mailer_setup_settings, {})
          put template.render(fetch(:mailer_template)), fetch(:mailer_remote_file)
        else
          puts "[FATAL] - Mailers template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:mailer_remote_file), File.join(local_rails_root, 'config/mailers.yml')
      end
    end
  end
end
