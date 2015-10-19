require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'
require 'chef_aws_provisioner/aws_utils'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['elasticsearch/amis'].each do |ami|
  tags = tagger.ami_tags(ami)

  machine_image tags['Name'] do
    action :destroy
  end
end
