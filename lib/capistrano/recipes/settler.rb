# Example
# =======
#
# settler_setup_settings:
#   host: example.com
#   partner_name: FooBar

Capistrano::Configuration.instance(:must_exist).load do
  set(:settler_remote_file) { File.join(shared_path, 'config/settler.yml') } unless exists?(:settler_remote_file)
  set(:settler_template, 'settler.yml.erb') unless exists?(:settler_template)

  # task: `settler:setup'
  def settler_template_settings
    fetch(:settler_setup_settings, {}).inject({}) do |r, (k,v)|
      r.merge Hash[k, {'alt' => k, 'value' => v}]
    end
  end


  # Required attributes
  # ===================
  # *settler_name* prod_db
  namespace :settler do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :db do
        if exists?(:settler_setup_settings)
           set(:recipe_settings) { settler_template_settings }
           put template.render(fetch(:settler_template)), fetch(:settler_remote_file)
         else
           puts "[FATAL] - Settler template settings were not found"
           abort
         end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download fetch(:settler_remote_file), File.join(local_rails_root, 'config/settler.yml')
      end
    end
  end
end
