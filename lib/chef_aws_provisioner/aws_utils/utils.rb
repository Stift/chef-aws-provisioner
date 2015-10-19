module ChefAWSProvisioner
  module Utils
    # Returns an unassociated Elastic IP if available, raises an error if non is available.
    #
    # @return [Object] An Elastic IP instance
    def available_elastic_ip
      addresses = ec2.vpc_addresses.select { |eip| eip unless eip.association_id }
      fail 'No Elastic IP available!' if addresses.empty?
      addresses.first
    end

    def humanize_duration(seconds)
      minutes = (seconds / 60).floor
      seconds = seconds % 60
      hours = (minutes / 60).floor
      minutes = minutes % 60
      days = (hours / 24).floor
      hours = hours % 24

      output = "#{seconds} second#{pluralize(seconds)}" if seconds > 0
      output = "#{minutes} minute#{pluralize(minutes)} and #{seconds} second#{pluralize(seconds)}" if minutes > 0
      output = "#{hours} hour#{pluralize(hours)}, #{minutes} minute#{pluralize(minutes)} and #{seconds} second#{pluralize(seconds)}" if hours > 0
      output = "#{days} day#{pluralize(days)}, #{hours} hour#{pluralize(hours)}, #{minutes} minute#{pluralize(minutes)} and #{seconds} second#{pluralize(seconds)}" if days > 0

      output
    end

    def pluralize(number)
      return 's' unless number == 1
      ''
    end
  end
end
