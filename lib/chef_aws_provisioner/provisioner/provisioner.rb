module ChefAWSProvisioner
  class Provisioner < Chef::Application::Client
    include Utils

    option :environment,
           short: '-E ENVIRONMENT',
           long: '--environment ENVIRONMENT',
           description: 'Set the Chef Environment on the node'

    option :yml_config,
           short: '-y ENVIRONMENT',
           long: '--yaml-config ENVIRONMENT',
           description: 'Set the YAML config file to use for provisioning.'
    def initialize
      @general_tasks = ['iam-roles']
      @no_config_tasks = ['defaults', 'internet-gateway', 'keys']
      @chef_repo_recipe_path = "#{Chef::Config.chef_repo_path}/provisioning"
      @local_recipe_path = "#{__FILE__}/../../provisioning"
      super()
    end

    private

    def load_config_file
      config[:config_file] = Chef::WorkstationConfigLoader.new(nil, Chef::Log).config_location
      super
    end

    def recipe_path(task)
      file_path = File.expand_path("#{@chef_repo_recipe_path}/#{task}.rb")
      return file_path if File.exist?(file_path)
      file_path = File.expand_path("#{@local_recipe_path}/#{task}.rb")
      return file_path if File.exist?(file_path)
      Chef::Log.info file_path
      fail "Could not load recipe #{task}!"
    end

    def reconfigure
      config[:local_mode] = true
      config[:client_fork] = false
      Chef::Config.chef_provisioning = {} unless Chef::Config.chef_provisioning
      super
      Chef::Config.provisioning_configs = "#{Chef::Config.chef_repo_path}/config/provisioning"
      content = begin
        YAML.load(File.open("#{Chef::Config.chef_repo_path}/config/provisioning/#{Chef::Config.environment}/general.yml"))
      rescue ArgumentError => e
        Chef::Application.fatal!("Could not parse YAML configuration: #{e.message}")
      end
      content.each { |key, value| Chef::Config.chef_provisioning[key] = value }
      @environment = Chef::Config.environment
    end

    # sets up a list of recipes to run.
    def set_specific_recipes
      Chef::Config[:specific_recipes] = if cli_arguments.respond_to?(:map)
                                          cli_arguments.map do |task|
                                            Chef::Config.chef_provisioning[task] = begin
                                              Chef::Log.info yml_config_path(task=task)
                                              YAML.load(File.open(yml_config_path(task=task)))
                                            rescue => e
                                              Chef::Application.fatal!("Could not parse YAML configuration: #{e.message}")
                                            end unless @no_config_tasks.include? task
                                            recipe_path(task)
                                          end
      end
    end

    def yml_config_path(task = nil)
      config[:yml_config] if config[:yml_config]
      return "#{Chef::Config.chef_repo_path}/config/provisioning/#{task}.yml" if @general_tasks.include? task
      return "#{Chef::Config.chef_repo_path}/config/provisioning/#{Chef::Config.environment}/#{task}.yml" if task
      return Chef::Config.provisioning_configs
    end
    # def run_application
    #   require 'pp'
    #   pp Chef::Config.chef_provisioning
    # end
  end
end
