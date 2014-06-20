class Machine
  attr_accessor :name, :status, :provider, :checked

  def initialize(name, status, provider, checked = true)
    @name = name
    @status = status.strip
    @provider = provider.strip
    @checked = checked
  end

  def up?
    @status == "running"
  end

  def checked?
    @checked
  end

  def is_virtualbox?
    @provider == "virtualbox"
  end
end
