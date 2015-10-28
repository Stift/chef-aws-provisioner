require 'tempfile'

module ChefAWSProvisioner
  module ApplicationsCommon
    def general_tasks
      ['iam-roles', 'keys']
    end

    def no_config_tasks
      ['general', 'internet-gateway', 'vpc-defaults']
    end

    def config_tasks
      %w(dhcp-options iam-roles keys launch-configuration load-balancer machine-images network-acls route-tables security-groups sns-topics subnets vpc-defaults vpc)
    end

    def locallog(msg)
      Chef::Log.info msg
    end

    def recipe_path(unprovision)
      Chef::Config.chef_provisioning['resource-type'] = "#{Chef::Config.chef_provisioning['resource-type']}_unprovision" if unprovision
      file_path = ::File.expand_path("#{chef_repo_recipe_path}/#{Chef::Config.chef_provisioning['resource-type']}.rb")
      if ::File.exist?(file_path)
        file_path
        # locallog("Set recipe path to #{file_path}")
      else
        file_path = ::File.expand_path("#{local_recipe_path}/#{Chef::Config.chef_provisioning['resource-type']}.rb")
        if ::File.exist?(file_path)
          file_path
          # locallog("Set recipe path to #{file_path}")
        else
          Chef::Application.fatal!("Could not find recipe for task #{Chef::Config.chef_provisioning['resource-type']}!")
        end
      end
    end

    def local_reconfigure(environment, task)
      config[:task] = task
      locallog("Set task to #{config[:task]}")
      config[:lockfile] = Tempfile.new('chef_provisioning')
      locallog("Set lockfile to #{config[:lockfile]}")
      config[:chef_zero_port] = rand(10_000..65_000)
      locallog("Set chef zero port to #{config[:chef_zero_port]}")
      Chef::Config.environment = environment
      locallog("Set environment to #{Chef::Config.environment}")
      reconfigure
    end

    def reconfigure
      Chef::Config.chef_provisioning_log_level = :info
      config[:local_mode] = true
      config[:client_fork] = false
      config[:lockfile] = Tempfile.new('chef_provisioning').path
      config[:chef_zero_port] = rand(10_000..65_000)
      Chef::Config.chef_provisioning = {} unless Chef::Config.chef_provisioning
      super
      locallog("Switched to local mode")
      locallog("Disabled forking")
      locallog("Set lockfile to #{config[:lockfile]}")
      locallog("Set chef zero port to #{config[:chef_zero_port]}")
      content = yml_config('general', get_config_option = false)
      locallog("Read general YML configuration file")
      content.each { |key, value| Chef::Config.chef_provisioning[key] = value }
      locallog("Loaded general YML configuration")
    end

    def task_configure
      unless no_config_tasks.include? config[:task]
        content = yml_config(config[:task])
        instances = content.delete('instances') if content.key? 'instances'
        content.each { |key, value| Chef::Config.chef_provisioning[key] = value }
        locallog("Loaded YML configuration for task #{config[:task]}")
        Chef::Config.chef_provisioning[Chef::Config.chef_provisioning['resource-type']] = instances if instances
        locallog("Set provisioning instances for task #{config[:task]}") if instances
      end
      Chef::Config.chef_provisioning['resource-type'] = config[:task] if no_config_tasks.include? config[:task]
    end
  end
end
