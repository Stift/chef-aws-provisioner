require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

utils = ChefAWSProvisioner::AWSUtils.new(config['region'], environment)

instance = { 'name' => 'Public' }
tags = tagger.route_table_tags(instance)

aws_route_table utils.default_route.id do
  vpc databag_name(tagger.vpc_tags['Name'])
  aws_tags tags
end

instance = { 'name' => 'Default' }

tags = tagger.network_acl_tags(instance)

tags['Notice'] = "This is the #{environment} VPC's default network ACL. It has been set to deny all traffic for security reasons!"

aws_network_acl utils.default_network_acl.id do
  aws_tags tags
  inbound_rules []
  outbound_rules []
  vpc databag_name(tagger.vpc_tags['Name'])
end

tags = tagger.security_group_tags(instance)

tags['Notice'] = "This is the #{environment} VPC's default security group. It has been emptied for security reasons!"

tags.delete('Description')

aws_security_group utils.default_security_group.id do
  aws_tags tags
  inbound_rules []
  outbound_rules []
  vpc databag_name(tagger.vpc_tags['Name'])
end
