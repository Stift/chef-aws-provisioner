require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['route-tables'].each do |rt|
  routes = {}

  rt['routes'].each do |key, value|
    value = value.to_sym if value == 'internet_gateway'
    routes[key] = value
  end

  tags = tagger.route_table_tags(rt)

  aws_route_table databag_name(tags['Name']) do
    aws_tags tags
    routes routes
    vpc databag_name(tagger.vpc_tags['Name'])
  end
end
