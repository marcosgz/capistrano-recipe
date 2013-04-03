Capistrano::Configuration.instance(:must_exist).load do
  # Required attributes
  # ===================
  # *license_key*  123xyz
  # *app_name* Production App
  namespace :newrelic do
    namespace :setup do
      desc "Upload configs"
      task :default, :roles => :app do
        if exists?(:newrelic_setup_settings)
          set(:recipe_settings) { newrelic_template_settings }
          puts template.render(_newrelic_template), _newrelic_remote_path
        else
          puts "[FATAL] - Newrelic template settings were not found"
          abort
        end
      end

      desc "Download configs"
      task :get, :roles => :db do
        download _newrelic_remote_path, _newrelic_local_path
      end
    end
  end

  def newrelic_setup_defaults
    HashWithIndifferentAccess.new({
      'common'      => {
        # ============================== LICENSE KEY ===============================

        # You must specify the license key associated with your New Relic
        # account.  This key binds your Agent's data to your account in the
        # New Relic service.
        'license_key' => self[:newrelic_license_key],
        # Agent Enabled (Ruby/Rails Only)
        # Use this setting to force the agent to run or not run.
        # Default is 'auto' which means the agent will install and run only
        # if a valid dispatcher such as Mongrel is running.  This prevents
        # it from running with Rake or the console.  Set to false to
        # completely turn the agent off regardless of the other settings.
        # Valid values are true, false and auto.
        # 'agent_enabled' => 'auto'

        # Application Name
        # Set this to be the name of your application as you'd like it show
        # up in New Relic.  New Relic will then auto-map instances of your application
        # into a New Relic "application" on your home dashboard page. If you want
        # to map this instance into multiple apps, like "AJAX Requests" and
        # "All UI" then specify a semicolon-separated list of up to three
        # distinct names.  If you comment this out, it defaults to the
        # capitalized RAILS_ENV (i.e., Production, Staging, etc)
        'app_name' => fetch(:application),

        # When "true", the agent collects performance data about your
        # application and reports this data to the New Relic service at
        # newrelic.com. This global switch is normally overridden for each
        # environment below. (formerly called 'enabled')
        'monitor_mode' => false,

        # Developer mode should be off in every environment but
        # development as it has very high overhead in memory.
        'developer_mode' => false,

        # The newrelic agent generates its own log file to keep its logging
        # information separate from that of your application.  Specify its
        # log level here.
        'log_level' => 'info',

        # The newrelic agent communicates with the New Relic service via http by
        # default.  If you want to communicate via https to increase
        # security, then turn on SSL by setting this value to true.  Note,
        # this will result in increased CPU overhead to perform the
        # encryption involved in SSL communication, but this work is done
        # asynchronously to the threads that process your application code,
        # so it should not impact response times.
        'ssl' => false,

        # EXPERIMENTAL: enable verification of the SSL certificate sent by
        # the server. This setting has no effect unless SSL is enabled
        # above. This may block your application. Only enable it if the data
        # you send us needs end-to-end verified certificates.
        #
        # This means we cannot cache the DNS lookup, so each request to the
        # New Relic service will perform a lookup. It also means that we cannot
        # use a non-blocking lookup, so in a worst case, if you have DNS
        # problems, your app may block indefinitely.
        # 'verify_certificate' => true,

        # Proxy settings for connecting to the New Relic server.
        #
        # If a proxy is used, the host setting is required.  Other settings
        # are optional.  Default port is 8080.
        #
        # 'proxy_host' => 'hostname'
        # 'proxy_port' => 8080
        # 'proxy_user' => ''
        # 'proxy_pass' => ''

        # Tells transaction tracer and error collector (when enabled)
        # whether or not to capture HTTP params.  When true, frameworks can
        # exclude HTTP parameters from being captured.
        # Rails: the RoR filter_parameter_logging excludes parameters
        # Java: create a config setting called "ignored_params" and set it to
        #     a comma separated list of HTTP parameter names.
        #     ex: ignored_params: credit_card, ssn, password
        'capture_params' => true,

        # Transaction tracer captures deep information about slow
        # transactions and sends this to the New Relic service once a
        # minute. Included in the transaction is the exact call sequence of
        # the transactions including any SQL statements issued.
        'transaction_tracer' => {
          # Transaction tracer is enabled by default. Set this to false to
          # turn it off. This feature is only available at the Professional
          # product level.
          'enabled' => true,

          # Threshold in seconds for when to collect a transaction
          # trace. When the response time of a controller action exceeds
          # this threshold, a transaction trace will be recorded and sent to
          # New Relic. Valid values are any float value, or (default) "apdex_f",
          # which will use the threshold for an dissatisfying Apdex
          # controller action - four times the Apdex T value.
          'transaction_threshold' => 'apdex_f',

          # When transaction tracer is on, SQL statements can optionally be
          # recorded. The recorder has three modes, "off" which sends no
          # SQL, "raw" which sends the SQL statement in its original form,
          # and "obfuscated", which strips out numeric and string literals.
          'record_sql' => 'raw',

          # Threshold in seconds for when to collect stack trace for a SQL
          # call. In other words, when SQL statements exceed this threshold,
          # then capture and send to New Relic the current stack trace. This is
          # helpful for pinpointing where long SQL calls originate from.
          'stack_trace_threshold' => 0.500

          # Determines whether the agent will capture query plans for slow
          # SQL queries.  Only supported in mysql and postgres.  Should be
          # set to false when using other adapters.
          # 'explain_enabled' => true

          # Threshold for query execution time below which query plans will not
          # not be captured.  Relevant only when `explain_enabled` is true.
          # 'explain_threshold' => 0.5
        },


        # Error collector captures information about uncaught exceptions and
        # sends them to New Relic for viewing
        'error_collector' => {
          # Error collector is enabled by default. Set this to false to turn
          # it off. This feature is only available at the Professional
          # product level.
          'enabled' => true,

          # Rails Only - tells error collector whether or not to capture a
          # source snippet around the place of the error when errors are View
          # related.
          'capture_source' => true,

          # To stop specific errors from reporting to New Relic, set this property
          # to comma-separated values.  Default is to ignore routing errors,
          # which are how 404's get triggered.
          'ignore_errors' => 'ActionController::RoutingError'
        },

        # (Advanced) Uncomment this to ensure the CPU and memory samplers
        # won't run.  Useful when you are using the agent to monitor an
        # external resource
        # 'disable_samplers' => true

        # If you aren't interested in visibility in these areas, you can
        # disable the instrumentation to reduce overhead.
        #
        # 'disable_view_instrumentation' => true,
        # 'disable_activerecord_instrumentation' => true,
        # 'disable_memcache_instrumentation' => true,
        # 'disable_dj' => true,

        # Certain types of instrumentation such as GC stats will not work if
        # you are running multi-threaded.  Please let us know.
        # 'multi_threaded' => false
      },
      'development' => {'developer_mode'  => true},
      'staging'     => {'developer_mode'  => true},
      'test'        => {},
      'production'  => {'monitor_mode'    => true}
    })
  end

  def newrelic_template_settings
    DeepToHash.to_hash newrelic_setup_defaults.deep_merge(fetch(:newrelic_setup_settings, {}))
  end

  def _newrelic_remote_path
    File.join(shared_path, fetch(:newrelic_remote_path, 'config/newrelic.yml'))
  end

  def _newrelic_local_path
    File.join(local_rails_root, fetch(:newrelic_local_path, 'config/newrelic.yml'))
  end

  def _newrelic_template
    fetch(:newrelic_template, 'newrelic.yml.erb')
  end
end
