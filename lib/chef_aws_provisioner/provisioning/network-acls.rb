require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'

def format_rule(rule)
  new_rule = {}
  new_rule[:action] = rule['action'].to_sym
  new_rule[:port] = rule['port'].to_i if rule.key? 'port'
  if rule.key?('from-port') && rule.key?('to-port')
    new_rule[:port] = Range.new(rule['from-port'], rule['to-port'])
  end
  rule['protocol'] = -1 if rule['protocol'] == 'any'
  new_rule[:protocol] = rule['protocol'].to_i
  new_rule[:cidr_block] = rule['cidr-block']
  new_rule[:rule_number] = rule['rule-number'].to_i
  new_rule
end

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['network-acls'].each do |acl|
  inbound_rules = []

  acl['outbound-rules'].each do |rule|
    inbound_rules.push(format_rule rule)
  end

  outbound_rules = []

  acl['outbound-rules'].each do |rule|
    outbound_rules.push(format_rule rule)
  end

  tags = tagger.network_acl_tags(acl)

  aws_network_acl tags['Name'] do
    aws_tags tags
    inbound_rules inbound_rules
    outbound_rules outbound_rules
    vpc Chef::Config.environment
  end
end
