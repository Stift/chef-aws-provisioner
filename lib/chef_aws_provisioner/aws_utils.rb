require 'aws-sdk'
require_relative 'aws_utils/ami'
require_relative 'aws_utils/by_name'
require_relative 'aws_utils/default'
require_relative 'aws_utils/ec2'
require_relative 'aws_utils/utils_windows'
require_relative 'aws_utils/utils'

module ChefAWSProvisioner
  class AWSUtils
    include Utils

    attr_reader :environment, :region, :vpc

    def initialize(region, environment)
      @region = region
      @environment = environment
      @vpc = vpc_by_name
    end
  end
end
