module ChefAWSProvisioner
  class Tagger
    def subnet_tags(instance)
      { 'Creator' => creator,
        'Description' => "#{instance['type'].capitalize} subnet in subnet segment #{instance['name']} on availability zone #{instance['availability-zone'].upcase} for the #{vpc_tags['Name']} VPC",
        'Name' => "#{vpc_tags['Name']} - #{instance['name']} #{instance['type'].capitalize} Subnet #{instance['availability-zone'].upcase}",
        'VPC Name' => vpc_tags['Name'] }
    end
  end
end
