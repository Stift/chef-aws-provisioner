require 'tempfile'

module ChefAWSProvisioner
  class Worker
    include Celluloid
    include Utils

    # initializes a worker instance
    #
    # @param [String] environment the environment to provision in
    # @param [Time] started_at the time that the parent operation started to run
    def initialize(environment, started_at, action)
      @environment = environment
      @started_at = started_at
      @action = action
      super()
    end

    def run_task(step, task)
      @step = step
      @task = task
      Chef::Log.debug "Running step #{step}, task #{task}."
      started_at = Time.now
      if @action == 'provision'
        application = ChefAWSProvisioner::Provisioner.new
      else
        application = ChefAWSProvisioner::Unprovisioner.new
      end
      lockfile = Tempfile.new('chef_provisioning')
      port = rand(10_000..65_000)
      application.local_reconfigure(@environment, task, lockfile, port)
      application.run
      sleep 2
      ended_at = Time.now
      duration step, task, started_at, ended_at
      Chef::Log.debug "Ran step #{step}, task #{task}."
    end

    private

    def duration(step, task, started_at, ended_at)
      time_range = humanize_duration(ended_at - started_at)
      Chef::Log.info "Running #{@action}ing step #{step}, task #{task} took #{time_range}."
    end

    def logpath
      "#{ENV['HOME']}/.chef/provisioning/.logs/#{@started_at.strftime('%Y%m%d%H%M%S%L')}"
    end

    def logfile
      log_dir_name = "#{logpath}/#{@step}"
      log_dir_name = "#{logpath}/#{@step}/#{::File.dirname(@task)}" if @task.include? '/'
      file_name = @task
      file_name = file_name.split('/')[-1] if @task.include? '/'
      "#{log_dir_name}/#{file_name}.log"
    end

    def run_system_command
      lockfile = Dir::Tmpname.create(['chef-provisioner', '.pid']) {}
      command = "OPSCODE_USER=#{ENV['OPSCODE_USER']} chef-#{@action}er -E #{@environment} --lockfile #{lockfile} #{@task} 2>&1"
      shell = Mixlib::ShellOut.new(command)
      shell.run_command
      write_log(shell.stdout)
      fail "Command '#{command}' failed while executing task #{@task} during step #{@step}! Find logs in: #{logfile}" if !shell.exitstatus || shell.exitstatus > 0
    end

    def write_log(stdout)
      FileUtils.mkdir_p(::File.dirname(logfile)) unless File.directory?(::File.dirname(logfile))
      File.open(logfile, 'wb') { |f| f.write(stdout) }
    end
  end
end
