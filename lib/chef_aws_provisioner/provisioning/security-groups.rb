require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner/tagger'

def format_rule(rule)
  new_rule = {}
  # new_rule[:port] = :any if (rule.key? 'port' && rule['port'] == 'any')
  # new_rule[:port] = rule['port'].to_i if (rule.key? 'port' && rule['port'] != 'any')
  new_rule[:port] = rule['port']
  if rule.key?('to-port') && rule.key?('from-port')
    new_rule[:port] = Range.new(rule['from-port'], rule['to-port'])
  end
  new_rule[:protocol] = rule['protocol'].to_sym if rule['protocol']
  new_rule[:sources] = rule['sources'] if rule['sources']
  new_rule[:destinations] = rule['destinations'] if rule['destinations']
  new_rule
end

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['security-groups'].each do |sg|
  inbound_rules = []

  sg['inbound-rules'].each do |rule|
    inbound_rules.push(format_rule rule)
  end

  outbound_rules = []

  sg['outbound-rules'].each do |rule|
    outbound_rules.push(format_rule rule)
  end

  tags = tagger.security_group_tags(sg)

  aws_security_group tags['Name'] do
    aws_tags tags
    inbound_rules inbound_rules
    outbound_rules outbound_rules
    vpc Chef::Config.environment
  end
end
