require 'chef/provisioning/aws_driver'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

Chef::Config.chef_provisioning['iam-roles'].each do |role|

  path = "#{Chef::Config.chef_repo_path}/config/provisioning"
  role_policy_json = IO.read("#{path}/iam-role-policies/#{role['role-policy']}.json")
  inline_policies_json = IO.read("#{path}/iam-inline-policies/#{role['inline-policies']}.json")

  aws_iam_role role['name'] do
    path role['path']
    assume_role_policy_document role_policy_json
    inline_policies role['inline-policies'].to_sym => inline_policies_json
  end

  aws_iam_instance_profile role['name'] do
    path role['path']
    role role['name']
  end

end
