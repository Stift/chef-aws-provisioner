require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['load-balancers'].each do |lb|
  tags = tagger.load_balancer_tags(lb)

  load_balancer tags['Name'] do
    action :destroy
  end
end
