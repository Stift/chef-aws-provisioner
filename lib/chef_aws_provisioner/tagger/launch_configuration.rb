module ChefAWSProvisioner
  class Tagger
    def launch_configuration_tags(instance)
      basic_tags(instance, 'launch configuration')
    end
  end
end
