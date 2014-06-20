describe "vagrant command" do
  before do
    @machines = [
        Machine.new("name1", "running", "virtualbox", true),
        Machine.new("name2", "running", "virtualbox", true),
    ]
  end

  it "up comannd given virtualbox machine" do
    VagrantCommand.new("/path/to", "up", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant up;"
      v.subcommand.should.equal "up"
    end
  end

  it "up comannd given virtualbox machines all checked" do
    VagrantCommand.new("/path/to", "up", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant up;"
    end
  end

  it "up comannd given virtualbox machines name1 checked" do
    @machines[1].checked = false

    VagrantCommand.new("/path/to", "up", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant up name1;"
    end
  end

  it "up comannd given virtualbox machines name2 checked" do
    @machines[0].checked = false

    VagrantCommand.new("/path/to", "up", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant up name2;"
    end
  end

  it "up comannd given virtualbox machines name2 has not virtualbox provider " do
    @machines[1].provider = 'aws'
    ;

    VagrantCommand.new("/path/to", "up", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant up name1; vagrant up name2 --provider=aws;"
    end
  end

  it "status comannd" do
    VagrantCommand.new("/path/to", "status", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant status;"
      v.subcommand.should.equal "status"
    end
  end

  it "subcomannd" do
    VagrantCommand.new("/path/to", "halt", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant halt;"
    end
  end

  it "subcomannd given machines name1 checked" do
    @machines[1].checked = false

    VagrantCommand.new("/path/to", "halt", @machines).tap do |v|
      v.makeScript.should.equal "cd /path/to; vagrant halt name1;"
    end
  end
end

