require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['security-groups'].each do |sg|
  tags = tagger.security_group_tags(sg)

  aws_security_group databag_name(tags['Name']) do
    action :destroy
    vpc databag_name(tagger.vpc_tags['Name'])
  end
end
