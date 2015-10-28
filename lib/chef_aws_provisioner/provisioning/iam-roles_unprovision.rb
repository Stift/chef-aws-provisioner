require_relative 'base'

config = Chef::Config.chef_provisioning

with_driver "aws::#{config['region']}"

config['iam-roles'].each do |role|
  aws_iam_instance_profile role['name'].slugify do
    action :destroy
  end

  aws_iam_role role['name'].slugify do
    action :destroy
  end
end
