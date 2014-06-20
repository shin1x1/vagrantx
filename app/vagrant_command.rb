class VagrantCommand
  attr_reader :subcommand

  def initialize(path, subcommand, machines)
    @path = path
    @subcommand = subcommand
    @machines = machines
  end

  def makeScript
    case @subcommand
      when "up"
        up(@machines)
      when "status"
        status
      else
        execute(@subcommand, @machines)
    end
  end

  def vagrantDir
    dir = @path
    if File.file?(dir) then
      dir = File.dirname(dir)
    end
    dir
  end

  def getBaseCommand
    command = "cd " + vagrantDir + ";"
  end

  def up(machines)
    command = getBaseCommand

    # all vbox && all checked
    if machines.all? { |m| m.is_virtualbox? } and machines.all? { |m| m.checked? }
      command += " vagrant up;"
      return command
    end

    machines.select { |m| m.checked? }.each do |m|
      if m.is_virtualbox?
        command += " vagrant up " + m.name + ";"
      else
        command += " vagrant up " + m.name + " --provider=" + m.provider + ";"
      end
    end

    command
  end

  def status
    getBaseCommand + " vagrant status;"
  end

  def execute(subcommand, machines)
    command = getBaseCommand

    if machines.all? { |m| m.checked? }
      command += " vagrant " + subcommand + ";"
    else
      machines.select { |m| m.checked? }.each do |m|
        command += " vagrant " + subcommand + " " + m.name + ";"
      end
    end

    command
  end
end
