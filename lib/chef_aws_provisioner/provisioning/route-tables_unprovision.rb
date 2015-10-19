require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['route-tables'].each do |rt|
  tags = tagger.route_tags(rt)

  aws_route_table tags['Name'] do
    action :destroy
    vpc Chef::Config.environment
  end
end
