require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

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

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['network-acls'].each do |acl|
  inbound_rules = []

  acl['outbound-rules'].each do |rule|
    inbound_rules.push(format_rule rule)
  end

  outbound_rules = []

  acl['outbound-rules'].each do |rule|
    outbound_rules.push(format_rule rule)
  end

  tags = tagger.network_acl_tags(acl)

  Chef::Log.info tags['Name']
  Chef::Log.info databag_name(tags['Name'])
  aws_network_acl databag_name(tags['Name']) do
    aws_tags tags
    inbound_rules inbound_rules
    outbound_rules outbound_rules
    vpc databag_name(tagger.vpc_tags['Name'])
  end
end
