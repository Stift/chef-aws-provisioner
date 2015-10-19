require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/aws_utils'
require 'chef_aws_provisioner/tagger'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['machine-images'].each do |image|
  tags = tagger.machine_image_tags(lc)

  aws_machine_image tags['Name'] do
    attributes image['attributes'] if image['attributes']
    aws_tags tags
    chef_environment image['chef_environment'] if image['chef_environment']
    complete image['complete'] if image['complete']
    ignore_failure image['ignore_failure'] if [true, false].include? image['ignore_failure']
    image_options image['image_options'] if image['image_options']
    machine_options image['machine_options']
    run_list image['run_list']
  end
end
