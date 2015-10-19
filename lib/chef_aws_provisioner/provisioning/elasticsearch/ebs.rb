require 'chef/provisioning/aws_driver'
require_relative '../settings'

with_driver "aws::#{CONFIG['region']}"
aws_ebs_volume "#{CONFIG['environment']}-elasticsearch-data" do
  size 256
  volume_type 'gp2'
  encrypted true
  device '/dev/sda2'
  aws_tags chef_type: 'aws_ebs_volume'
end
