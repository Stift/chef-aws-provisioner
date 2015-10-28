module ChefAWSProvisioner
  module Utils
    # Fetches an AMI object instance of the given OS.
    #
    # @param root_device_type [String] The type of root device volume to search for
    # @param os [String] The name of the operating system
    #
    # @return [Object] The last item of a list of AMI instances sorted by name
    def latest_ami(os)
      raise ArgumentError, "OS #{os} is not supported! Only windows and ubuntu are..." unless %w(ubuntu windows).include? os
      method("latest_#{os}_ami".to_sym).call
    end

    # Fetches an Ubuntu AMI object instance.
    #
    # @param root_device_type [String] The type of root device volume to search for
    # @param ami_name [String] The name of the AMI image to serach for, can contain wildcard characters
    #
    # @return [Object] The last item of a list of AMI instances sorted by name
    def latest_ubuntu_ami(root_device_type = 'ebs', ami_name = '*hvm-ssd/ubuntu-trusty-14.04*')
      options = {
        owners: ['099720109477'],
        filters: ami_filters(root_device_type, ami_name)
      }
      fetch_ami(options)
    end

    # Fetches a Windows AMI object instance.
    #
    # @param root_device_type [String] The type of root device volume to search for
    # @param ami_name [String] The name of the AMI image to serach for, can contain wildcard characters
    #
    # @return [Object] The last item of a list of AMI instances sorted by name
    def latest_windows_ami(root_device_type = 'ebs', ami_name = 'Windows_Server-2012-R2_RTM-English-64Bit-Base*')
      options = {
        filters: ami_filters(root_device_type, ami_name)
      }
      fetch_ami(options)
    end

    private

    def ami_filters(root_device_type, ami_name)
      [
        {
          name: 'name',
          values: [ami_name]
        },
        {
          name: 'root-device-type',
          values: [root_device_type]
        }
      ]
    end

    def fetch_ami(options)
      ec2.images(options).to_a.sort_by(&:name).last
    end
  end
end
