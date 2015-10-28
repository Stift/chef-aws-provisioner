require 'chef/provisioning/aws_driver'
require_relative '../settings'

with_driver "aws::#{CONFIG['region']}" do
  %w(data). each do |es_type|
    aws_auto_scaling_group "#{CONFIG['environment']}-elasticsearch-#{es_type}" do
      action :destroy
    end

    aws_launch_configuration "#{CONFIG['environment']}-elasticsearch-#{es_type}" do
      action :destroy
    end
  end
end
