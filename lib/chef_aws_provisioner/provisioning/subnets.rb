require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

utils = ChefAWSProvisioner::AWSUtils.new(config['region'], environment)

tagger = ChefAWSProvisioner::Tagger.new environment

config['subnets'].each do |subnet|
  tags = tagger.subnet_tags(subnet)
  if subnet['route-table']
    instance = { 'type' => subnet['type'], 'name' => subnet['route-table'] }
    route_table = databag_name(tagger.route_table_tags(instance)['Name'])
  else
    route_table = utils.default_route.id
  end
  if subnet['acl']
    instance = { 'type' => subnet['type'], 'name' => subnet['acl'] }
    network_acl = databag_name(tagger.network_acl_tags(instance)['Name'])
  else
    network_acl = utils.default_network_acl.id
  end

  vpc = databag_name(tagger.vpc_tags['Name'])
  vpc = subnet['vpc'] if subnet['vpc']

  aws_subnet databag_name(tags['Name']) do
    availability_zone "#{config['region']}#{subnet['availability-zone']}"
    aws_tags tags
    cidr_block "#{subnet['address']}/#{subnet['prefix']}"
    map_public_ip_on_launch subnet['type'] == 'public' ? true : false
    network_acl network_acl
    route_table route_table
    vpc vpc
  end
end
