Capistrano::Configuration.instance(:must_exist).load do
  namespace :mailer do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:mailer_setup_settings)
          set(:recipe_settings) { mailer_template_settings }
          put template.render(_mailer_template), _mailer_remote_file
        else
          puts "[FATAL] - Mailers template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _mailer_remote_file, _mailer_local_file
      end
    end
  end

  def mailer_setup_defaults
    HashWithIndifferentAccess.new({
      'common'      => {},
      'development' => {},
      'production'  => {},
      'test'        => {}
    })
  end

  def mailer_template_settings
    DeepToHash.to_hash mailer_setup_defaults.deep_merge(fetch(:mailer_setup_settings, {}))
  end

  def _mailer_remote_file
    File.join(shared_path, fetch(:mailer_remote_file, 'config/mailers.yml'))
  end

  def _mailer_local_file
    File.join(local_rails_root, fetch(:mailer_local_file, 'config/mailers.yml'))
  end

  def _mailer_template
    fetch(:mailer_template, 'mailers.yml.erb')
  end
end
