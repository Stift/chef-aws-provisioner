require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/aws_utils'
require 'chef_aws_provisioner/tagger'

utils = ChefAWSProvisioner::AWSUtils.new(Chef::Config.chef_provisioning['region'], Chef::Config.environment)

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['subnets'].each do |subnet|
  tags = tagger.subnet_tags(subnet)
  if subnet['route-table']
    route_table = "#{Chef::Config.environment}-#{subnet['route-table']}"
  else
    route_table = utils.default_route.id
  end
  aws_subnet tags['Name'] do
    availability_zone "#{Chef::Config.chef_provisioning['region']}#{subnet['availability-zone']}"
    aws_tags tags
    cidr_block "#{subnet['address']}/#{subnet['prefix']}"
    map_public_ip_on_launch subnet['type'] == 'public' ? true : false
    network_acl "#{Chef::Config.environment}-#{subnet['acl']}"
    route_table route_table
    vpc Chef::Config.environment
  end
end
