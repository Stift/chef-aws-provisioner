module ChefAWSProvisioner
  class Tagger
    def network_acl_tags(instance)
      basic_tags(instance, 'network ACL')
    end
  end
end
