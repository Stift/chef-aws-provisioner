require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{CONFIG['region']}" do

tagger = ChefAWSProvisioner::Tagger.new environment

config['sns-topics'].each do |sns|
  tags = tagger.sns_topic_tags(sns)

  aws_sns_topic databag_name(tags['Name']) do
    aws_tags tags
  end
end
