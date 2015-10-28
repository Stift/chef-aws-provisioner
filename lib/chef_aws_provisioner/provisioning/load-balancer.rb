require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['load-balancers'].each do |lb|
  tags = tagger.load_balancer_tags(lb)

  listeners = []
  lb['listeners'].each do |listener|
    listeners.push({
      :port => listener['port'],
      :protocol => listener['protocol'].to_sym,
      :instance_port => listener['instance-port'],
      :instance_protocol => listener['instance-protocol'].to_sym
  })
  end

  load_balancer databag_name(tags['Name']) do
    aws_tags tags
    load_balancer_options(
      lazy do
        {listeners: listeners,
          scheme: lb["scheme"],
          subnets: lb['subnets'],
          security_groups: lb['security-groups']
       },
       attributes: {
        cross_zone_load_balancing: {
          enabled: lb['cross-zone-load-balancing']
        }
      }
      end
     )
  end

end
