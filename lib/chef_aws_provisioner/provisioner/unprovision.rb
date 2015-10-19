module ChefAWSProvisioner
  class Unprovision < Chef::Application::Client
    include Utils

    # initializes an instance
    #
    # @param [String] environment the environment to provision in
    def initialize(environment)
      @environment = environment
      @started_at = Time.now
      super()
    end

    private

    def load_config_file
      config[:config_file] = Chef::WorkstationConfigLoader.new(nil, Chef::Log).config_location
      super
    end

    def logpath
      "#{ENV['HOME']}/.chef/provisioning/.logs/#{@started_at.strftime('%Y-%m-%d %H:%M:%S.%L')}"
    end

    def reconfigure
      config[:local_mode] = true
      super
      Chef::Config.environment = @environment
      Chef::Config.chef_provisioning = begin
        YAML.load(File.open("#{Chef::Config.chef_repo_path}/config/provisioning/#{Chef::Config.environment}/general.yml"))
      rescue ArgumentError, Errno::ENOENT => e
        Chef::Application.fatal!("Could not parse YAML configuration file: #{e.message}")
      end
      Chef::Config.chef_provisioning['unprovision'] = begin
        YAML.load(File.open("#{Chef::Config.chef_repo_path}/config/provisioning/#{Chef::Config.environment}/unprovision.yml"))
      rescue ArgumentError, Errno::ENOENT => e
        Chef::Application.fatal!("Could not parse YAML configuration file: #{e.message}")
      end
    end

    def run_application
      Chef::Log.info("Starting unprovisioning of environment #{@environment}.")
      Chef::Config.chef_provisioning['unprovision'].each do |step, tasks|
        pool = UnprovisionWorker.pool(size: tasks.length, args: [Chef::Config.environment, @started_at])
        workers = tasks.map do |task|
          begin
            pool.future(:run_task, step, task)
          rescue => e
            Chef::Application.fatal!(e.message)
          end
        end
        workers.compact.each do |worker|
          begin
            worker.value
          rescue
            nil
          end
        end
      end
      Chef::Log.info("Logs can be found at: \"#{Shellwords.escape(logpath)}\"")
      ended_at = Time.now
      time_range = humanize_duration(ended_at - @started_at)
      Chef::Log.info("Running took #{time_range}.")
    end
  end
end
