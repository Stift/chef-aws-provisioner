require 'chef/provisioning/aws_driver'

utils = ChefAWSProvisioner::AWSUtils.new Chef::Config.chef_provisioning['region']

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['security-groups'].each do |sg|
  tags = tagger.security_group_tags(sg)

  aws_security_group tags['Name'] do
    action :destroy
    vpc Chef::Config.environment
  end
end
