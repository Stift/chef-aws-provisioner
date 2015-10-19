module ChefAWSProvisioner
  class Tagger
    def security_group_tags(instance)
      basic_tags(instance, 'security group')
    end
  end
end
