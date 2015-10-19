module ChefAWSProvisioner
  module Utils

    # Returns a route table in a given VPC.
    #
    # @param name [String] The name of the route table to search for.
    #
    # @return [Object] A route table instance
    def route_by_name(name)
      collection = ec2.route_tables(filter_options(name))
      f = []
      collection.map { |e| f.push e }
      fail "Name of route table was not unique! Got #{f.length} route tables with name '#{name}'" if f.length > 1
      f[0]
    end

    # Returns a security group in a given VPC.
    #
    # @param name [String] The name of the security group to search for.
    #
    # @return [Object] A security group instance
    def security_group_by_name(name)
      collection = ec2.security_groups(filter_options(name))
      f = []
      collection.map { |e| f.push e }
      fail "Name of security group was not unique! Got #{f.length} security groups with name '#{name}'" if f.length > 1
      f[0]
    end

    # Returns a subnet in a given VPC.
    #
    # @param name [String] The name of the subnet to search for.
    #
    # @return [Object] A subnet instance
    def subnet_by_name(name)
      collection = ec2.subnets(filter_options(name))
      f = []
      collection.map { |e| f.push e }
      fail "Name of subnet was not unique! Got #{f.length} subnets with name '#{name}'" if f.length > 1
      f[0]
    end

    # Returns an VPC instance.
    #
    # @param name [String] The name of the VPC to search for.
    #
    # @return [Object] A VPC instance
    def vpc_by_name
      collection = ec2.vpcs(vpc_filter_options)
      f = []
      collection.map { |e| f.push e }
      fail "Name of VPC was not unique! Got #{f.length} VPC's with name '#{@environment}'" if f.length > 1
      f[0]
    end

    private

    def filter_options(name)
      {
        filters:
          [
            {
              name: 'vpc-id',
              values: [@vpc.id]
            },
            {
              name: 'tag:Name',
              values: [name]
            }
          ]
      }
    end

    def vpc_filter_options
      {
        filters:
          [
            {
              name: 'tag:Name',
              values: [@environment]
            }
          ]
      }
    end
  end
end
