require 'chef/provisioning/aws_driver'
require_relative '../settings'

with_driver "aws::#{CONFIG['region']}"

load_balancer "#{CONFIG['environment']}-elasticsearch-client" do
  load_balancer_options(
    lazy do
      {:listeners => [{
        :port => 9200,
        :protocol => :http,
        :instance_port => 9200,
        :instance_protocol => :http,
    }],
        scheme: "internet-facing",
        subnets: [ "#{CONFIG['environment']}-subnet-a",  "#{CONFIG['environment']}-subnet-b"],
        security_groups: ["#{CONFIG['environment']}-sg-base", "#{CONFIG['environment']}-sg-elasticsearch"]
     },
     attributes: {
      cross_zone_load_balancing: {
        enabled: true
      }
    }
    end
   )
end
