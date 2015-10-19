module ChefAWSProvisioner
  class Tagger
    def route_table_tags(instance)
      basic_tags(instance, 'route table')
    end
  end
end
