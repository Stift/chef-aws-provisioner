require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

tags = tagger.internet_gateway_tags

aws_internet_gateway databag_name(tags['Name']) do
  action :destroy
end
