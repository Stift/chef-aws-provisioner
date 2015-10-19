require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'

utils = ChefAWSProvisioner::AWSUtils.new Chef::Config.chef_provisioning['region']

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['subnets'].each do |subnet|
  tags = tagger.subnet_tags(subnet)

  aws_subnet tags['Name'] do
    action :destroy
    vpc Chef::Config.environment
  end
end
