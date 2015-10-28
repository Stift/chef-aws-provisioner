require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

tags = tagger.dhcp_options_tags

aws_dhcp_options databag_name(tags['Name']) do
  action :destroy
end
