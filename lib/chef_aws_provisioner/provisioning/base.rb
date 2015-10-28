require 'chef/provisioning/aws_driver'
require 'chef_aws_provisioner'
require 'slugify'

def databag_name(name)
  name.slugify(trim = true)
end
