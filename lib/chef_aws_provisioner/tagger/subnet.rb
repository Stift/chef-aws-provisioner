module ChefAWSProvisioner
  class Tagger
    def subnet_tags(instance)
      { 'Creator' => creator,
        'Description' => "#{instance['type'].capitalize} subnet on availability zone #{instance['availability-zone'].upcase} for the #{@environment} VPC",
        'Name' => "#{@environment}-#{instance['name']}-#{instance['type']}-#{instance['availability-zone']}" }
    end
  end
end
