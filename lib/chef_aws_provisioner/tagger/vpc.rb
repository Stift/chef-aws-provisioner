module ChefAWSProvisioner
  class Tagger
    def dhcp_options_tags
      { 'Creator' => creator,
        'Description' => "DHCP options for the #{vpc_tags['Name']} VPC",
        'Name' => "#{vpc_tags['Name']} DHCP options",
        'VPC Name' => vpc_tags['Name'] }
    end

    def internet_gateway_tags
      { 'Creator' => creator,
        'Description' => "Internet gateway for the #{vpc_tags['Name']} VPC",
        'Name' =>  "#{vpc_tags['Name']} internet gateway",
        'VPC Name' => vpc_tags['Name'] }
    end

    def vpc_tags
      { 'Creator' => creator,
        'Description' => "VPC for the #{@environment} environment",
        'Name' =>  @environment }
    end
  end
end
