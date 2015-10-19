require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/aws_utils'
require 'chef_aws_provisioner/tagger'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['launch-configurations'].each do |lc|
  tags = tagger.launch_configuration_tags(lc)

    aws_launch_configuration tags['Name'] do
      action :destroy
    end
end
