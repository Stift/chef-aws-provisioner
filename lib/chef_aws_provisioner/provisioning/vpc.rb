require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

tags = tagger.vpc_tags

# pp databag_name(tags['Name'])
aws_vpc databag_name(tags['Name']) do
  aws_tags tags
  cidr_block config['cidr-block']
  dhcp_options databag_name(tagger.dhcp_options_tags['Name'])
  enable_dns_hostnames config['enable-dns-hostnames']
  enable_dns_support config['enable-dns-support']
  instance_tenancy config['instance-tenancy'].to_sym
  internet_gateway databag_name(tagger.internet_gateway_tags['Name'])
  main_routes '0.0.0.0/0' => :internet_gateway
end
