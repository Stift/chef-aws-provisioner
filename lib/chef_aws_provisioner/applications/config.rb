module ChefAWSProvisioner
  module Config
    def local_recipe_path
      ::File.expand_path("#{__FILE__}/../../provisioning")
    end

    def chef_repo_recipe_path
      ::File.expand_path("#{Chef::Config.chef_repo_path}/provisioning")
    end

    def load_config_file
      config[:config_file] = Chef::WorkstationConfigLoader.new(nil, Chef::Log).config_location
      super
    end

    def yml_config(task, get_config_option = true)
      if get_config_option && config[:yml_config]
        file = config[:yml_config]
      else
        file = yml_config_path(task)
      end
      locallog "Parsing YML configuration from file #{file}"
      begin
        YAML.load(File.open(file))
      rescue ArgumentError => e
        Chef::Application.fatal!("Could not parse YML configuration: #{e.message}")
      end
    end

    def yml_config_path(task = nil)
      if general_tasks.include? task
        dir = "#{Chef::Config.chef_repo_path}/config/provisioning"
      else
        dir = "#{Chef::Config.chef_repo_path}/config/provisioning/#{Chef::Config.environment}"
      end
      locallog "Returning YML configuration path #{dir}/#{task}.yml"
      "#{dir}/#{task}.yml"
    end
  end
end
