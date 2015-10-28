require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['load-balancers'].each do |lb|
  tags = tagger.load_balancer_tags(lb)

  load_balancer databag_name(tags['Name']) do
    action :destroy
  end
end
