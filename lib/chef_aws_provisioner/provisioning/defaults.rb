require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

utils = ChefAWSProvisioner::AWSUtils.new(Chef::Config.chef_provisioning['region'], Chef::Config.environment)

instance = { 'name' => 'public' }
tags = tagger.route_table_tags(instance)

aws_route_table utils.default_route.id do
  vpc Chef::Config.environment
  aws_tags tags
end

instance = { 'name' => 'default' }

tags = tagger.network_acl_tags(instance)

tags['Notice'] = "This is the #{Chef::Config.environment} VPC's default network ACL. It has been set to deny all traffic for security reasons!"

aws_network_acl utils.default_network_acl.id do
  aws_tags tags
  inbound_rules []
  outbound_rules []
  vpc Chef::Config.environment
end

tags = tagger.security_group_tags(instance)

tags['Notice'] = "This is the #{Chef::Config.environment} VPC's default security group. It has been emptied for security reasons!"

aws_security_group utils.default_security_group.id do
  aws_tags tags
  inbound_rules []
  outbound_rules []
  vpc Chef::Config.environment
end
