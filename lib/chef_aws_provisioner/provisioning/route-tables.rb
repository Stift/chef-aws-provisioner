require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['route-tables'].each do |rt|
  routes = {}

  rt['routes'].each do |key, value|
    value = value.to_sym if value == 'internet_gateway'
    routes[key] = value
  end

  tags = tagger.route_table_tags(rt)

  aws_route_table tags['Name'] do
    aws_tags tags
    routes routes
    vpc Chef::Config.environment
  end
end
