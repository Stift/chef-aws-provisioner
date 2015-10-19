module ChefAWSProvisioner
  class Tagger
    def machin_image_tags(instance)
      basic_tags(instance, 'machine image')
    end
  end
end
