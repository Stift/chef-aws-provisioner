require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'
require 'chef_aws_provisioner/aws_utils'

instance = ChefAWSProvisioner::AWSUtils.new Chef::Config.chef_provisioning['region']

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['elasticsearch/amis'].each do |ami|
  tags = tagger.ami_tags(ami)

  machine_image tags['Name'] do
    action :destroy
  end

  image_id = ami['image-id']
  image_id = instance.latest_ami(ami['os']).image_id if ami['image-id'] == "latest"

  security_groups = []
  ami['security-group-ids'].map { |e| security_groups.push("#{Chef::Config.environment}-#{e}")  }

  machine_image tags['Name'] do
    run_list ami['run_list']
    chef_environment Chef::Config.environment
    machine_options bootstrap_options: {
      availability_zone: "#{Chef::Config.chef_provisioning['region']}#{ami['availability-zone']}",
      iam_instance_profile: ami['iam-instance-profile'],
      image_id: instance.latest_ubuntu_ami.image_id,
      instance_type: ami['instance-type'],
      security_group_ids: security_groups,
      subnet: "#{Chef::Config.environment}-#{ami['subnet']}",
      key_name: "#{Chef::Config.environment}-key-pair"
    },
                    convergence_options: {
                      allow_overwrite_keys: true,
                      ssl_verify_mode: :verify_none
                    },
                    use_private_ip_for_ssh: ami['use-private-ip-for-ssh'],
                    transport_address_location: ami['transport-address-location'].to_sym,
                    create_timeout: ami['create-timeout'],
                    start_timeout: ami['start-timeout'],
                    aws_tags: tags
  end
end
