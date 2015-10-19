require 'chef/provisioning/aws_driver'

with_driver "aws::#{CONFIG['region']}" do


tagger = ChefAWSProvisioner::Tagger.new Chef::Config.environment

Chef::Config.chef_provisioning['sns-topics'].each do |sns|
  tags = tagger.sns_topic_tags(sns)

  aws_sns_topic tags['Name'] do
    aws_tags tags
  end
end
