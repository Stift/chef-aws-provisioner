module ChefAWSProvisioner
  module Utils
    # Returns the default network ACL of a given VPC.
    #
    # @return [Object] A network ACL instance
    def default_network_acl
      filters = {
        filters:
          [
            {
              name: 'vpc-id',
              values: [@vpc.id]
            },
            {
              name: 'default',
              values: ['true']
            }
          ]
      }
      collection = ec2.network_acls(filters)
      f = []
      collection.map { |e| f.push e }
      # fail "Name of route table was not unique! Got #{f.length} route tables with name '#{name}'" if f.length > 1
      f[0]
    end

    # Returns the default route table of a given VPC.
    #
    # @return [Object] A route table instance
    def default_route
      filters = {
        filters:
          [
            {
              name: 'vpc-id',
              values: [@vpc.id]
            },
            {
              name: 'association.main',
              values: ['true']
            }
          ]
      }
      collection = ec2.route_tables(filters)
      f = []
      collection.map { |e| f.push e }
      # fail "Name of route table was not unique! Got #{f.length} route tables with name '#{name}'" if f.length > 1
      f[0]
    end

    # Returns the default security group of a given VPC.
    #
    # @return [Object] A network ACL instance
    def default_security_group
      filters = {
        filters:
          [
            {
              name: 'vpc-id',
              values: [@vpc.id]
            },
            {
              name: 'group-name',
              values: ['default']
            }
          ]
      }
      collection = ec2.security_groups(filters)
      f = []
      collection.map { |e| f.push e }
      f[0]
    end
  end
end
