module ChefAWSProvisioner
  class Tagger
    def iam_role_tags(instance)
      basic_tags(instance, 'IAM role')
    end
  end
end
