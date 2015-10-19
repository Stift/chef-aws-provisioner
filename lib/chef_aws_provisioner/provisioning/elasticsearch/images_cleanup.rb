require 'chef/provisioning/aws_driver'
require_relative '../settings'

with_driver "aws::#{CONFIG['region']}"

%w(client data master). each do |es_type|
  machine_image "#{CONFIG['environment']}-elasticsearch-#{es_type}" do
    action :destroy
  end
end
