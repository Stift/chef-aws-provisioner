module ChefAWSProvisioner
  module Utils
    def ec2
      @ec2 ||= Aws::EC2::Resource.new(region: @region)
      @ec2
    end
  end
end
