require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/aws_utils'
require 'chef_aws_provisioner/tagger'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['launch-configurations'].each do |lc|
  tags = tagger.launch_configuration_tags(lc)

    block_device_mappings = []
    # block_device_mappings = [
    #   {
    #     device_name: '/dev/sde',
    #     ebs: {
    #       delete_on_termination: true,
    #       volume_type: 'gp2',
    #       volume_size: 100 # 1 GB
    #     }
    #   }] if  es_type == 'data.new'

    aws_launch_configuration tags['Name'] do
      image "#{Chef::Config.environment}-#{lc['image']}"
      instance_type lc'instance_type']
      options security_groups: lc['security-groups'],
              iam_instance_profile: lc['iam-profile'],
              availability_zone: "#{Chef::Config.environment}-#{lc['availability-zone']}",
              key_name: "#{CONFIG['environment']}-key-pair",
              block_device_mappings: block_device_mappings
    end


end
