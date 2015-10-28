require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

tags = tagger.dhcp_options_tags

aws_dhcp_options databag_name(tags['Name']) do
  aws_tags tags
  domain_name "#{config['region']}.compute.internal"
  domain_name_servers config['domain-name-servers']
  ntp_servers config['ntp-servers'] if config['ntp-servers']
  netbios_name_servers config['netbios-name-servers'] if config['netbios-name-servers']
  netbios_node_type config['netbios-node-type'] if config['netbios-node-type']
end
