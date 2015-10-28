require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

def format_rule(rule, recipient)
  new_rule = {}
  if rule['ports']
    rule['ports'].each do |port|
      dynarule = { 'port' => port, 'protocol' => rule['protocol'] }
      dynarule['sources'] = rule['sources'] if rule['sources']
      dynarule['destinations'] = rule['destinations'] if rule['destinations']
      format_rule(dynarule, recipient)
    end
  else
    new_rule[:port] = rule['port']
    if rule.key?('to-port') && rule.key?('from-port')
      new_rule[:port] = Range.new(rule['from-port'], rule['to-port'])
    end
    new_rule[:protocol] = rule['protocol'].to_sym if rule['protocol']
    new_rule[:sources] = rule['sources'] if rule['sources']
    new_rule[:destinations] = rule['destinations'] if rule['destinations']
    recipient.push(new_rule)
  end
end

with_driver "aws::#{config['region']}"

tagger = ChefAWSProvisioner::Tagger.new environment

config['security-groups'].each do |sg|
  inbound_rules = []

  sg['inbound-rules'].each do |rule|
    format_rule(rule, inbound_rules)
  end

  outbound_rules = []

  sg['outbound-rules'].each do |rule|
    format_rule(rule, outbound_rules)
  end

  tags = tagger.security_group_tags(sg)

  description = tags.delete('Description')

  aws_security_group databag_name(tags['Name']) do
    aws_tags tags
    description description
    inbound_rules inbound_rules
    outbound_rules outbound_rules
    vpc databag_name(tagger.vpc_tags['Name'])
  end
end
