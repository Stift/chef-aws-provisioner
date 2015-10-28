module ChefAWSProvisioner
  module ProvisionCommon
    private

    def general_tasks
      []
    end

    def local_application
      Chef::Log.info("Starting #{@action}ing of environment #{Chef::Config.environment}.")
      Chef::Config.chef_provisioning[@action].each do |step, tasks|
        pool = ChefAWSProvisioner::Worker.pool(size: Chef::Config.chef_provisioning[:workers], args: [Chef::Config.environment, @started_at, @action])
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

    def logpath
      "#{ENV['HOME']}/.chef/provisioning/.logs/#{@started_at.strftime('%Y%m%d%H%M%S%L')}"
    end

    def post_config
      Chef::Config.environment = cli_arguments[0]
      Chef::Config.chef_provisioning = {} unless Chef::Config.chef_provisioning
      content = yml_config('general', get_config_option = false)
      content.each { |key, value| Chef::Config.chef_provisioning[key] = value }
      task_configure(@action)
      Chef::Config.chef_provisioning[:workers] = config[:workers]
    end

    def reconfigure
      config[:local_mode] = true
      config[:client_fork] = false
      super
      post_config
    end

    def run_application
      # require 'pp'
      # pp Chef::Config.chef_provisioning
      local_application
    end

    def task_configure(task)
      content = yml_config(task)
      Chef::Config.chef_provisioning[task] = {} unless Chef::Config.chef_provisioning.key? task
      content.each { |key, value| Chef::Config.chef_provisioning[task][key] = value }
    end
  end
end
