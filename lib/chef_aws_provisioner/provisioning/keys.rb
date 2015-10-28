require_relative 'base'

config = Chef::Config.chef_provisioning
environment = Chef::Config.environment

with_driver "aws::#{config['region']}"

config['keys'].each do |key|
  aws_key_pair key['name'].slugify do
    private_key_options(format:                  key['format'].to_sym,
                        type:                    key['type'].to_sym,
                        regenerate_if_different: key['regenerate-if-different'])
    allow_overwrite key['allow-overwrite']
  end
end
