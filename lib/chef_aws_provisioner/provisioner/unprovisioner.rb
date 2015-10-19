module ChefAWSProvisioner
  class Unprovisioner < Chef::Application::Client
    include Utils

    option :environment,
           short: '-E ENVIRONMENT',
           long: '--environment ENVIRONMENT',
           description: 'Set the Chef Environment on the node'

   def initialize
     @general_tasks = ['iam-roles']
     @no_config_tasks = ['defaults', 'internet-gateway', 'keys']
     @chef_repo_recipe_path = "#{Chef::Config.chef_repo_path}/provisioning"
     @local_recipe_path = "#{__FILE__}/../../provisioning"
     super()
     @general_tasks = ['iam-roles']
   end

    private

    def load_config_file
      config[:config_file] = Chef::WorkstationConfigLoader.new(nil, Chef::Log).config_location
      super
    end

    def yml_config(task=nil)
      if @general_tasks.include? task
        "#{Chef::Config.chef_repo_path}/config/provisioning"
      else
        "#{Chef::Config.chef_repo_path}/config/provisioning/#{Chef::Config.environment}"
      end

    end

    def reconfigure
      config[:local_mode] = true
      config[:client_fork] = false
      Chef::Config.chef_provisioning = {} unless Chef::Config.chef_provisioning
      super
      content = begin
        YAML.load(File.open("#{yml_config}/general.yml"))
      rescue ArgumentError => e
        Chef::Application.fatal!("Could not parse YAML configuration: #{e.message}")
      end
      content.each { |key, value| Chef::Config.chef_provisioning[key] = value }
      @environment = Chef::Config.environment
      Chef::Config.provisioning_configs = "#{Chef::Config.chef_repo_path}/config/provisioning"
    end

    # sets up a list of recipes to run.
    def set_specific_recipes
      Chef::Config[:specific_recipes] = if cli_arguments.respond_to?(:map)
        cli_arguments.map do |task|
          # @task_yml_path = "#{@task_yml_path}/#{Chef::Config.environment}" unless @general_tasks.include? task
          Chef::Config.chef_provisioning[task] = begin
            YAML.load(File.open("#{yml_config(task=task)}/#{task}.yml"))
          rescue => e
            Chef::Application.fatal!("Could not parse YAML configuration: #{e.message}")
          end unless @no_config_tasks.include? task
          File.expand_path("#{__FILE__}/../../provisioning/#{task}_unprovision.rb")
        end
      end
    end

    # def run_application
    #   require 'pp'
    #   pp Chef::Config.chef_provisioning
    # end
  end
end
