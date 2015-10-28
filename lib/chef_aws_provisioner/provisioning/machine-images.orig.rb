require_relative 'base'

require 'pp'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

utils = ChefAWSProvisioner::AWSUtils.new(config['region'], environment)

tagger = ChefAWSProvisioner::Tagger.new environment

config['machine-images'].each do |image|
  # tags = tagger.machine_image_tags(image)

  Chef::Log.info 1
  if image['image-id'] == 'latest'
    Chef::Log.info '1a'
    ami = utils.latest_ami image['os']
    Chef::Log.info 2
    ami_id = ami.id
    Chef::Log.info 3
  else
    ami_id = image['image-id']
    Chef::Log.info 4
  end

  Chef::Log.info 5
  case image['transport-address-location']
  when 'public'
    transport_address_location = :public_ip
  when 'private'
    transport_address_location = :private_ip
  when 'dns'
    transport_address_location = :dns
  else
    fail "Unsupported transport-address-location #{image['transport-address-location']} given. Supported are: public, private, dns"
  end

  Chef::Log.info 3
  security_groups = []
  image['security-groups'].each { |sg| security_groups.push("#{environment}-#{sg}") }

  Chef::Log.info 4
  bootstrap_options = {}
  bootstrap_options['iam_instance_profile'] = image['iam-instance-profile']
  bootstrap_options['image_id'] = ami_id
  bootstrap_options['instance_type'] = image['instance-type']
  bootstrap_options['security_group_ids'] = security_groups
  bootstrap_options['subnet'] = "#{environment}-#{image['subnet']}"
  bootstrap_options['key_name'] = image['key_name'] if image['key-name']

  convergence_options = {}
  convergence_options['allow_overwrite_keys'] = image['allow-overwrite-keys']
  convergence_options['ssl_verify_mode'] = image['ssl-verify-mode']

  machine_options = {}
  machine_options['bootstrap_options'] = bootstrap_options
  machine_options['convergence_options'] = convergence_options
  machine_options['use_private_ip_for_ssh'] = image['use-private-ip-for-ssh']
  machine_options['transport_address_location'] = transport_address_location
  machine_options['create_timeout'] = image['create-timeout']
  machine_options['start_timeout'] = image['start-timeout']

  pp machine_options

  # aws_machine_image databag_name(tags['Name']) do
  #   attributes image['attributes'] if image['attributes']
  #   aws_tags tags
  #   chef_environment image['chef_environment'] if image['chef_environment']
  #   complete image['complete'] if image['complete']
  #   ignore_failure image['ignore_failure'] if [true, false].include? image['ignore_failure']
  #   image_options image['image_options'] if image['image_options']
  #   machine_options machine_options
  #   run_list image['run_list']
  # end
end

# require 'chef/provisioning/aws_driver'
# require_relative '../settings'
#
# with_driver "aws::#{CONFIG['region']}"
#
# require 'citytouch/aws'
# instance = Citytouch::AWS::Compute.new(region: CONFIG['region'])
#
# %w(data). each do |es_type|
#   machine_image "#{CONFIG['environment']}-elasticsearch-#{es_type}" do
#     action :destroy
#   end
#   machine_image "#{CONFIG['environment']}-elasticsearch-#{es_type}" do
#     role "elasticsearch-#{es_type}"
#     chef_environment CONFIG['environment']
#     machine_options bootstrap_options: {
#       availability_zone: "#{CONFIG['region']}a",
#       iam_instance_profile: 'ElasticsearchCluster',
#       image_id: instance.latest_ubuntu_ami.image_id,
#       instance_type: 'm3.large',
#       security_group_ids: ["#{CONFIG['environment']}-sg-base", "#{CONFIG['environment']}-sg-elasticsearch"],
#       subnet: "#{CONFIG['environment']}-subnet-a",
#       key_name: "#{CONFIG['environment']}-key-pair"
#     },
#                     convergence_options: {
#                       allow_overwrite_keys: true,
#                       ssl_verify_mode: :verify_none
#                     },
#                     use_private_ip_for_ssh: false,
#                     transport_address_location: :public_ip,
#                     create_timeout: 600,
#                     start_timeout: 600,
#                     aws_tags: { chef_type: 'aws_machine', Creator: "chef-provisioning/#{ENV['OPSCODE_USER']}", Description: 'Elasticsearch #{es_type} node', Name: "#{CONFIG['environment']}-elasticsearch-#{es_type}" }
#   end
# end
