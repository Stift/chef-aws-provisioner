module ChefAWSProvisioner
  class Unprovision < Chef::Application::Client
    include Utils
    include Config
    include ProvisionCommon

    option :workers,
           short:       '-w MAX_WORKERS',
           long:        '--workers MAX_WORKERS',
           description: 'Determines how many workers to be in the pool.',
           proc:        ->(s) { s.to_i }

    def initialize
      @started_at = Time.now
      @action     = 'unprovision'
      super()
    end
  end
end
