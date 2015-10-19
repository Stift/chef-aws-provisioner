module ChefAWSProvisioner
  class Tagger
    def dhcp_options_tags
      { 'Creator' => creator,
        'Description' => "DHCP options for the #{@environment} VPC",
        'Name' =>  @environment }
    end

    def vpc_tags
      { 'Creator' => creator,
        'Description' => "VPC for the #{@environment} environment",
        'Name' =>  @environment }
    end

    def internet_gateway_tags
      { 'Creator' => creator,
        'Description' => "Internet gateway for the #{@environment} VPC",
        'Name' =>  @environment }
    end
  end
end
