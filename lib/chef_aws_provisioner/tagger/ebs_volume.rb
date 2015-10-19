module ChefAWSProvisioner
  class Tagger
    def ebs_volume_tags(instance)
      basic_tags(instance, 'EBS volume')
    end
  end
end
