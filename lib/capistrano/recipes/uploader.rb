Capistrano::Configuration.instance(:must_exist).load do
  namespace :uploader do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:uploader_setup_settings)
          set(:recipe_settings) { uploader_template_settings }
          put template.render(_uploader_template), _uploader_remote_file
        else
          puts "[FATAL] - Uploader template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _uploader_remote_file, _uploader_local_file
      end
    end

  end

  def uploader_setup_defaults
    HashWithIndifferentAccess.new({
      'common'      => {},
      'development' => {},
      'production'  => {},
      'test'        => {}
    })
  end

  def uploader_template_settings
    DeepToHash.to_hash uploader_setup_defaults.deep_merge(fetch(:uploader_setup_settings, {}))
  end

  def _uploader_remote_file
    File.join(shared_path, fetch(:uploader_remote_file, 'config/uploader.yml'))
  end

  def _uploader_local_file
    File.join(local_rails_root, fetch(:uploader_local_file, 'config/uploader.yml'))
  end

  def _uploader_template
    fetch(:uploader_template, 'uploader.yml.erb')
  end

end
