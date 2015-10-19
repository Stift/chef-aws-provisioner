module ChefAWSProvisioner
  class Tagger
    def sns_topic_tags(instance)
      basic_tags(instance, 'SNS topic')
    end
  end
end
