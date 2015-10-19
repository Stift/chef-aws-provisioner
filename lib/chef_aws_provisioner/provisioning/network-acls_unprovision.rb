require 'chef/provisioning/aws_driver'

utils = ChefAWSProvisioner::AWSUtils.new Chef::Config.chef_provisioning['region']

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['network-acls'].each do |acl|
  tags = tagger.network_acl_tags(acl)

  aws_network_acl tags['Name'] do
    action :destroy
    vpc Chef::Config.environment
  end
end
