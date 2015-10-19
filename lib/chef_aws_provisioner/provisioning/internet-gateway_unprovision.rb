require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

tags = tagger.internet_gateway_tags

aws_internet_gateway tags['Name'] do
    action :destroy
end
