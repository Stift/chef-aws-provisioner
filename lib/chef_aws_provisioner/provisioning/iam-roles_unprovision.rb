require 'chef/provisioning/aws_driver'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

Chef::Config.chef_provisioning['iam-roles'].each do |role|

  aws_iam_instance_profile role['name'] do
    action :destroy
  end

  aws_iam_role role['name'] do
    action :destroy
  end

end
