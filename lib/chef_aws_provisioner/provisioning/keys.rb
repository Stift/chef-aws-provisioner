require 'chef/provisioning/aws_driver'

with_driver "aws::#{Chef::Config.chef_provisioning['region']}"

aws_key_pair Chef::Config.environment do
  private_key_options(format:                  :pem,
                      type:                    :rsa,
                      regenerate_if_different: false)
  allow_overwrite false
end
