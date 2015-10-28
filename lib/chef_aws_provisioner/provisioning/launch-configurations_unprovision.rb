require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['launch-configurations'].each do |lc|
  tags = tagger.launch_configuration_tags(lc)

  aws_launch_configuration databag_name(tags['Name']) do
    action :destroy
  end
end
