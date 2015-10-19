module ChefAWSProvisioner
  class UnprovisionWorker
    include Celluloid
    include Utils

    # initializes a worker instance
    #
    # @param [String] environment the environment to provision in
    # @param [Time] started_at the time that the parent operation started to run
    def initialize(environment, started_at)
      @environment = environment
      @started_at = started_at
      super()
    end

    def run_task(step, task)
      @task = task
      Chef::Log.debug "Running step #{step}, task #{task}."
      started_at = Time.now
      command = "chef-unprovisioner -E #{@environment} #{@task}"
      run_system_command(command, step, task)
      ended_at = Time.now
      duration step, task, started_at, ended_at
      Chef::Log.debug "Ran step #{step}, task #{task}."
    end

    private

    def duration(step, task, started_at, ended_at)
      time_range = humanize_duration(ended_at - started_at)
      Chef::Log.info "Running step #{step}, task #{task} took #{time_range}."
    end

    def logpath
      "#{ENV['HOME']}/.chef/provisioning/.logs/#{@started_at.strftime('%Y-%m-%d %H:%M:%S.%L')}"
    end

    def run_system_command(command, step, task)
      log_dir_name = "#{logpath}/#{step}"
      shell = Mixlib::ShellOut.new("OPSCODE_USER=#{ENV['OPSCODE_USER']} #{command} 2>&1")
      shell.run_command
      write_log(step, task, shell.stdout)
      log_path = Shellwords.escape("#{log_dir_name}/#{task}.log")
      fail "Command '#{command}' failed while executing task #{task} during step #{step}! Find logs in: #{log_path}" if !shell.exitstatus || shell.exitstatus > 0
    end

    def write_log(step, task, stdout)
      log_dir_name = "#{logpath}/#{step}"
      FileUtils.mkdir_p(log_dir_name) unless File.directory?(log_dir_name)
      File.open("#{log_dir_name}/#{task}.log", 'wb') { |f| f.write(stdout) }
    end
  end
end
