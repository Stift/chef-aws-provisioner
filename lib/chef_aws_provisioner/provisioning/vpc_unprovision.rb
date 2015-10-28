require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

aws_vpc databag_name(tagger.vpc_tags['Name']) do
  action :purge
end
