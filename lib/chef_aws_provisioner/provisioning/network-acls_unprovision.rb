require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['network-acls'].each do |acl|
  tags = tagger.network_acl_tags(acl)

  aws_network_acl databag_name(tags['Name']) do
    action :destroy
    vpc databag_name(tagger.vpc_tags['Name'])
  end
end
