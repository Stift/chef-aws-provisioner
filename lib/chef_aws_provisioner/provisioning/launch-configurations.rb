require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['launch-configurations'].each do |lc|
  tags = tagger.launch_configuration_tags(lc)

    aws_launch_configuration databag_name(tags['Name']) do
      aws_tags tags
      image "#{environment}-#{lc['image']}"
      instance_type lc'instance_type']
      options security_groups: lc['security-groups'],
              iam_instance_profile: lc['iam-profile'],
              availability_zone: "#{environment}-#{lc['availability-zone']}",
              key_name: "#{environment}-key-pair",
              block_device_mappings: lc['block_device_mappings']
    end
end
