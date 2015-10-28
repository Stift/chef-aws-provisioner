module ChefAWSProvisioner
  class Provision < Chef::Application::Client
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
      @action     = 'provision'
      super()
    end
  end
end
