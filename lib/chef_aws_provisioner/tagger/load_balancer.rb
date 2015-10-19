module ChefAWSProvisioner
  class Tagger
    def load_balancer_tags(instance)
      basic_tags(instance, 'load balancer')
    end
  end
end
