require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['subnets'].each do |subnet|
  tags = tagger.subnet_tags(subnet)

  aws_subnet databag_name(tags['Name']) do
    action :destroy
    vpc databag_name(tagger.vpc_tags['Name'])
  end
end
