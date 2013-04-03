Capistrano::Configuration.instance(:must_exist).load do
  namespace :settler do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:settler_setup_settings)
           set(:recipe_settings) { settler_template_settings }
           put template.render(_settler_template), _settler_remote_file
         else
           puts "[FATAL] - Settler template settings were not found"
           abort
         end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _settler_remote_file, _settler_local_file
      end
    end
  end

  def settler_template_settings
    fetch(:settler_setup_settings, {}).inject({}) do |r, (k,v)|
      case v.class.name
      when 'Hash', 'ActiveSupport::HashWithIndifferentAccess'
        r[k] = v
      when 'Float'
        r[k] = {'alt' => k.to_s, 'value' => v.to_s, 'typecast' => 'float'}
      when 'Fixnum'
        r[k] = {'alt' => k.to_s, 'value' => v.to_s, 'typecast' => 'integer'}
      when 'TrueClass', 'FalseClass'
        r[k] = {'alt' => k.to_s, 'value' => v.to_s, 'typecast' => 'boolean'}
      when 'DateTime', 'Date', 'Time'
        r[k] = {'alt' => k.to_s, 'value' => v.to_s, 'typecast' => 'datetime'}
      else
        r[k] = {'alt' => k.to_s, 'value' => v.to_s}
      end
      r
    end
  end

  def _settler_remote_file
    File.join(shared_path, fetch(:settler_remote_file, 'config/settler.yml'))
  end

  def _settler_local_file
    File.join(local_rails_root, fetch(:settler_local_file, 'config/settler.yml'))
  end

  def _settler_template
    fetch(:settler_template, 'settler.yml.erb')
  end
end
