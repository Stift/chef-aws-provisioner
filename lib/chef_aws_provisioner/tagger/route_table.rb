module ChefAWSProvisioner
  class Tagger
    def route_table_tags(instance)
      { 'Creator' => creator,
        'Description' => "#{instance['name']} #{instance['type']} route table for the #{vpc_tags['Name']} VPC",
        'Name' =>  "#{vpc_tags['Name']} - #{instance['name']} #{instance['type']} route table",
        'VPC Name' => vpc_tags['Name'] }
    end
  end
end
