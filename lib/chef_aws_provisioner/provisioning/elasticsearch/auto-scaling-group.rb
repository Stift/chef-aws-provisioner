require 'chef/provisioning/aws_driver'
require_relative '../settings'

with_driver "aws::#{CONFIG['region']}" do
  topic = aws_sns_topic "#{CONFIG['environment']}-elasticsearch-notifications" do
  end

  %w(data). each do |es_type|
    dimensions = [{ name: 'AutoScalingGroupName', value: "#{CONFIG['environment']}-elasticsearch-#{es_type}" }]

    block_device_mappings = []
    # block_device_mappings = [
    #   {
    #     device_name: '/dev/sde',
    #     ebs: {
    #       delete_on_termination: true,
    #       volume_type: 'gp2',
    #       volume_size: 100 # 1 GB
    #     }
    #   }] if  es_type == 'data.new'

    aws_launch_configuration "#{CONFIG['environment']}-elasticsearch-#{es_type}" do
      image "#{CONFIG['environment']}-elasticsearch-#{es_type}"
      instance_type CONFIG['elasticsearch'][es_type]['instance_type']
      options security_groups: ["#{CONFIG['environment']}-sg-base", "#{CONFIG['environment']}-sg-elasticsearch"],
              iam_instance_profile: 'ElasticsearchCluster',
              availability_zone: "#{CONFIG['region']}a",
              key_name: "#{CONFIG['environment']}-key-pair",
              block_device_mappings: block_device_mappings
    end

    asg_instance = aws_auto_scaling_group "#{CONFIG['environment']}-elasticsearch-#{es_type}-auto-scaling-group" do
      desired_capacity CONFIG['elasticsearch'][es_type]['autoscalinggroup']['desired_capacity']
      min_size CONFIG['elasticsearch'][es_type]['autoscalinggroup']['min_size']
      max_size CONFIG['elasticsearch'][es_type]['autoscalinggroup']['max_size']
      launch_configuration "#{CONFIG['environment']}-elasticsearch-#{es_type}-launch-configuration"
      load_balancers "#{CONFIG['environment']}-elasticsearch-#{es_type}" if es_type == 'client'
      options subnets: ["#{CONFIG['environment']}-subnet-a", "#{CONFIG['environment']}-subnet-b"],
              health_check_type: CONFIG['elasticsearch'][es_type]['autoscalinggroup']['health_check_type'],
              health_check_grace_period: CONFIG['elasticsearch'][es_type]['autoscalinggroup']['health_check_grace_period'],
              default_cooldown: CONFIG['elasticsearch'][es_type]['autoscalinggroup']['default_cooldown']
      notifies :run, "ruby_block[Configure elasticsearch #{es_type} Autoscale Group]", :immediately
    end

    # Hacky, but works for now.
    ruby_block "Configure elasticsearch #{es_type} Autoscale Group" do
      block do
        asg_instance.aws_object.notification_configurations.create(
          topic: topic.aws_object,
          types: [
            'autoscaling:EC2_INSTANCE_LAUNCH',
            'autoscaling:EC2_INSTANCE_TERMINATE'
          ]
        )

        scale_out_policy = asg_instance.aws_object.scaling_policies.create("#{CONFIG['environment']}-elasticsearch-#{es_type}-scale-out-policy",
                                                                           adjustment_type: CONFIG['elasticsearch'][es_type]['scale_out']['adjustment_type'],
                                                                           scaling_adjustment: CONFIG['elasticsearch'][es_type]['scale_out']['scaling_adjustment'],
                                                                           cooldown: CONFIG['elasticsearch'][es_type]['scale_out']['cooldown']
                                                                          )

        cw = AWS::CloudWatch.new
        cw.alarms.create("#{CONFIG['environment']}-elasticsearch-#{es_type}-scale-out-alarm",
                         alarm_actions: [scale_out_policy.arn],
                         comparison_operator: CONFIG['elasticsearch'][es_type]['scale_out']['comparison_operator'],
                         dimensions: dimensions,
                         evaluation_periods: CONFIG['elasticsearch'][es_type]['scale_out']['evaluation_periods'],
                         metric_name: CONFIG['elasticsearch'][es_type]['scale_out']['metric_name'],
                         namespace: CONFIG['elasticsearch'][es_type]['scale_out']['namespace'],
                         period: CONFIG['elasticsearch'][es_type]['scale_out']['period'],
                         statistic: CONFIG['elasticsearch'][es_type]['scale_out']['statistic'],
                         threshold: CONFIG['elasticsearch'][es_type]['scale_out']['threshold']
                        #            :alarm_description => "scale-out if CPU > #{node['autoscale']['ScaleUpCPUThreshold']}% for #{node['autoscale']['AlarmPeriod'] * node['autoscale']['AlarmEvaluationPeriods'] / 60} minutes"
                        )

        scale_in_policy = asg_instance.aws_object.scaling_policies.create("#{CONFIG['environment']}-elasticsearch-#{es_type}-scale-in-policy",
                                                                          adjustment_type: CONFIG['elasticsearch'][es_type]['scale_in']['adjustment_type'],
                                                                          scaling_adjustment: CONFIG['elasticsearch'][es_type]['scale_in']['scaling_adjustment'],
                                                                          cooldown: CONFIG['elasticsearch'][es_type]['scale_in']['cooldown']
                                                                         )

        cw = AWS::CloudWatch.new
        cw.alarms.create("#{CONFIG['environment']}-elasticsearch-#{es_type}-scale-in-alarm",
                         alarm_actions: [scale_in_policy.arn],
                         comparison_operator: CONFIG['elasticsearch'][es_type]['scale_in']['comparison_operator'],
                         dimensions: dimensions,
                         evaluation_periods: CONFIG['elasticsearch'][es_type]['scale_in']['evaluation_periods'],
                         metric_name: CONFIG['elasticsearch'][es_type]['scale_in']['metric_name'],
                         namespace: CONFIG['elasticsearch'][es_type]['scale_in']['namespace'],
                         period: CONFIG['elasticsearch'][es_type]['scale_in']['period'],
                         statistic: CONFIG['elasticsearch'][es_type]['scale_in']['statistic'],
                         threshold: CONFIG['elasticsearch'][es_type]['scale_in']['threshold']
                        #            :alarm_description => "scale-out if CPU > #{node['autoscale']['ScaleUpCPUThreshold']}% for #{node['autoscale']['AlarmPeriod'] * node['autoscale']['AlarmEvaluationPeriods'] / 60} minutes"
                        )
      end
      action :run
    end
  end
end
