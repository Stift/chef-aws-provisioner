require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'
require 'chef_aws_provisioner/aws_utils'

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['elasticsearch/amis'].each do |ami|
  tags = tagger.ami_tags(ami)

  machine_image tags['Name'] do
    action :destroy
  end
end
