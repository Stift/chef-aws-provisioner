require 'chef/provisioning/aws_driver'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

aws_vpc Chef::Config.environment do
  action :purge
end

aws_dhcp_options Chef::Config.environment do
  action :destroy
end
