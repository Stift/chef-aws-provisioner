module ChefAWSProvisioner
  class Provisioner < Chef::Application::Client
    include Utils
    include ApplicationsCommon
    include Config

    option :environment,
           short:       '-E ENVIRONMENT',
           long:        '--environment ENVIRONMENT',
           description: 'Set the Chef Environment'

    # option :lockfile,
    #        long:        '--lockfile LOCKFILE',
    #        description: 'Set the lockfile location. Prevents multiple client processes from converging at the same time',
    #        proc:        nil

    option :task,
           short:       '-t TASK',
           long:        '--task TASK',
           description: 'The provisioning task to perform',
           proc:        nil

    def set_specific_recipes
      task_configure
      locallog("Configured task #{config[:task]}")
      Chef::Config[:specific_recipes] = [recipe_path(false)]
    end

    # def run_application
    #   require 'pp'
    #   pp Chef::Config.chef_provisioning
    # end
  end
end
