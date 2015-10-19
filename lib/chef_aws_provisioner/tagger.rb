require_relative 'tagger/iam_role'
require_relative 'tagger/launch_configuration'
require_relative 'tagger/load_balancer'
require_relative 'tagger/machine_image'
require_relative 'tagger/network_acl'
require_relative 'tagger/route_table'
require_relative 'tagger/security_group'
require_relative 'tagger/sns_topic'
require_relative 'tagger/subnet'
require_relative 'tagger/vpc'

module ChefAWSProvisioner
  class Tagger
    def initialize(environment)
      @environment = environment
    end

    def creator
      ENV['OPSCODE_USER']
    end

    def basic_tags(instance, type)
      { 'Creator' => creator,
        'Description' => "#{instance['name'].capitalize} #{type} for the #{@environment} VPC",
        'Name' =>  "#{@environment}-#{instance['name']}" }
    end
  end
end
