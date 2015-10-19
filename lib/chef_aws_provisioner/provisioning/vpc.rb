require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

# The DHCP options need to be created before the VPC and must be configured for
# use in a VPC. A VPC's DHCP options cannot be changed!

tags = tagger.dhcp_options_tags

aws_dhcp_options tags['Name'] do
  aws_tags tags
  domain_name "#{Chef::Config.chef_provisioning['region']}.compute.internal"
  domain_name_servers Chef::Config.chef_provisioning['vpc']['domain-name-servers']
  ntp_servers Chef::Config.chef_provisioning['vpc']['ntp-servers'] if Chef::Config.chef_provisioning['vpc']['ntp-servers']
  netbios_name_servers Chef::Config.chef_provisioning['vpc']['netbios-name-servers'] if Chef::Config.chef_provisioning['vpc']['netbios-name-servers']
  netbios_node_type Chef::Config.chef_provisioning['vpc']['netbios-node-type'] if Chef::Config.chef_provisioning['vpc']['netbios-node-type']
end

vpc_tags = tagger.vpc_tags

aws_vpc vpc_tags['Name'] do
  aws_tags vpc_tags
  cidr_block Chef::Config.chef_provisioning['vpc']['cidr-block']
  dhcp_options Chef::Config.environment
  enable_dns_hostnames Chef::Config.chef_provisioning['vpc']['enable-dns-hostnames']
  enable_dns_support Chef::Config.chef_provisioning['vpc']['enable-dns-support']
  instance_tenancy Chef::Config.chef_provisioning['vpc']['instance-tenancy'].to_sym
  internet_gateway Chef::Config.environment
  main_routes '0.0.0.0/0' => :internet_gateway
end

# utils = ChefAWSProvisioner::AWSUtils.new Chef::Config.chef_provisioning['region']
# 
# utils.environment = Chef::Config.environment
#
# instance = { 'name' => 'public' }
# tags = tagger.route_tags(instance)
#
# aws_route_table utils.default_route.id do
#   vpc vpc_tags['Name']
#   aws_tags tags
# end
#
# instance = { 'name' => 'default' }
#
# tags = tagger.network_acl_tags(instance)
#
# tags['Notice'] = "This is the #{Chef::Config.environment} VPC's default network ACL. It has been set to deny all traffic for security reasons!"
#
# aws_network_acl utils.default_network_acl.id do
#   vpc vpc_tags['Name']
#   inbound_rules []
#   outbound_rules []
#   aws_tags tags
# end
#
# tags = tagger.security_group_tags(instance)
#
# tags['Notice'] = "This is the #{Chef::Config.environment} VPC's default security group. It has been emptied for security reasons!"
#
# aws_security_group utils.default_security_group.id do
#   aws_tags tags
#   inbound_rules []
#   outbound_rules []
#   vpc vpc_tags['Name']
# end
