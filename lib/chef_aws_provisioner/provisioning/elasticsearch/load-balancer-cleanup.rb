require 'chef/provisioning/aws_driver'
require_relative '../settings'

with_driver "aws::#{CONFIG['region']}"

load_balancer "#{CONFIG['environment']}-elasticsearch-client" do
  action :destroy
end
