class MainController
  def initialize
    @machines = []

    @text_url = NSTextField.alloc.initWithFrame(NSMakeRect(11, 450, 400, 22))
    @text_url.stringValue = '~'
    @text_url.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin|NSViewWidthSizable
    app.window.contentView.addSubview(@text_url)

    button = NSButton.alloc.initWithFrame(NSMakeRect(415, 444, 61, 32))
    button.title = 'Read'
    button.action = :'readVagrantfile:'
    button.target = self
    button.bezelStyle = NSRoundedBezelStyle
    button.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin
    app.window.contentView.addSubview(button)

    @buttonUp = NSButton.alloc.initWithFrame(NSMakeRect(10, 400, 61, 32)).tap do |b|
      b.title = 'Up'
      b.action = :'up:'
      b.target = self
      b.bezelStyle = NSRoundedBezelStyle
      b.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin
      app.window.contentView.addSubview(b)
    end

    @buttonHalt = NSButton.alloc.initWithFrame(NSMakeRect(70, 400, 61, 32)).tap do |b|
      b.title = 'Halt'
      b.action = :'halt:'
      b.target = self
      b.bezelStyle = NSRoundedBezelStyle
      b.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin
      app.window.contentView.addSubview(b)
    end

    @buttonDestroy = NSButton.alloc.initWithFrame(NSMakeRect(130, 400, 80, 32)).tap do |b|
      b.title = 'Destroy'
      b.action = :'destroy:'
      b.target = self
      b.bezelStyle = NSRoundedBezelStyle
      b.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin
      app.window.contentView.addSubview(b)
    end

    @buttonProvision = NSButton.alloc.initWithFrame(NSMakeRect(210, 400, 80, 32)).tap do |b|
      b.title = 'Provision'
      b.action = :'provision:'
      b.target = self
      b.bezelStyle = NSRoundedBezelStyle
      b.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin
      app.window.contentView.addSubview(b)
    end

    @tableView = NSTableView.alloc.init.tap do |table|
      scroll = NSScrollView.alloc.initWithFrame(NSMakeRect(10, 270, 480, 120))
      scroll.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin|NSViewWidthSizable|NSViewHeightSizable
      scroll.hasVerticalScroller = true
      scroll.setBorderType(NSBezelBorder)

      app.window.contentView.addSubview(scroll)

      table.autoresizingMask = NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin
      table.delegate = self
      table.target = self
      table.dataSource = self

      NSTableColumn.alloc.initWithIdentifier('check').tap do |column|
        column.editable = false
        column.headerCell.setTitle('')
        column.width = 30

        cell = NSButtonCell.alloc.init
        cell.setEditable(true)
        cell.setButtonType(NSSwitchButton)
        cell.setTitle('')
        cell.target = self
        cell.action = :'checkTableRow:'
        column.setDataCell(cell)

        table.addTableColumn(column)
      end

      NSTableColumn.alloc.initWithIdentifier('name').tap do |column|
        column.editable = false
        column.headerCell.setTitle('name')
        column.width = 100
        table.addTableColumn(column)
      end

      NSTableColumn.alloc.initWithIdentifier('status').tap do |column|
        column.editable = false
        column.headerCell.setTitle('status')
        column.width = 120
        table.addTableColumn(column)
      end

      NSTableColumn.alloc.initWithIdentifier('provider').tap do |column|
        column.editable = false
        column.headerCell.setTitle('provider')
        column.width = 150
        table.addTableColumn(column)
      end

      NSTableColumn.alloc.initWithIdentifier('ssh').tap do |column|
        column.editable = false
        column.headerCell.setTitle('ssh')
        column.width = 60

        cell = NSButtonCell.alloc.init
        cell.setEditable(false)
        cell.setTitle('ssh')
        cell.target = self
        cell.action = :'sshWithMachine:'
        column.setDataCell(cell)

        table.addTableColumn(column)
      end

      scroll.setDocumentView(table)
    end

    NSScrollView.alloc.initWithFrame(NSMakeRect(10, 10, 480, 200)).tap do |scroll|
      scroll.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin|NSViewWidthSizable|NSViewHeightSizable
      scroll.hasVerticalScroller = true
      scroll.setBorderType(NSBezelBorder)
      app.window.contentView.addSubview(scroll)

      @logTextView = NSTextView.alloc.initWithFrame(scroll.contentView.bounds)
      @logTextView.insertText('Log')
      scroll.setDocumentView(@logTextView)
    end

    toggleButtonsEnable(true)
  end

  def app
    NSApp.delegate
  end

  def readVagrantfile(sender)
    dialog = NSOpenPanel.openPanel
    dialog.canChooseFiles = true
    dialog.canChooseDirectories = true
    dialog.allowsMultipleSelection = false

    if dialog.runModalForDirectory(@text_url.stringValue, file: nil) == NSOKButton
      @text_url.stringValue = dialog.filenames.first
      @logTextView.setString('')

      toggleButtonsEnable(true)
      vagrant(VagrantCommand.new(@text_url.stringValue, 'status', @machines))
    end
  end

  def checkTableRow(sender)
    machine = @machines[sender.selectedRow]
    if machine.checked?
      machine.checked = false
    else
      machine.checked = true
    end
    toggleButtonsEnable
  end

  def up(sender)
    toggleButtonsEnable(true)
    vagrant(VagrantCommand.new(@text_url.stringValue, 'up', @machines))
  end

  def halt(sender)
    toggleButtonsEnable(true)
    vagrant(VagrantCommand.new(@text_url.stringValue, 'halt', @machines))
  end

  def destroy(sender)
    NSAlert.alertWithMessageText('it will destroy VMs',
                                 defaultButton: 'No',
                                 alternateButton: 'Yes',
                                 otherButton: nil,
                                 informativeTextWithFormat: 'Are you sure?').tap do |alert|
      alert.runModal.tap do |ret|
        p ret
        if ret == 0
          toggleButtonsEnable(true)
          vagrant(VagrantCommand.new(@text_url.stringValue, 'destroy -f', @machines))
        end
      end
    end
  end

  def provision(sender)
    toggleButtonsEnable(true)
    vagrant(VagrantCommand.new(@text_url.stringValue, 'provision', @machines))
  end

  def ssh(sender)
    script = 'tell application "Terminal" to do script "cd ' + vagrantDir + ' && vagrant ssh\''
    NSAppleScript.alloc.initWithSource(script).executeAndReturnError(nil)
  end

  def sshWithMachine(sender)
    machine = @machines[@tableView.selectedRow]
    script = 'tell application "Terminal" to activate do script "cd ' + vagrantDir + ' && vagrant ssh '+ machine.name + '\''
    NSAppleScript.alloc.initWithSource(script).executeAndReturnError(nil)
  end

  def openBrowserWithMachine(sender)
    machine = @machines[@tableView.selectedRow]

    url =
        script = 'tell application "Terminal" to do script "open ' + vagrantDir + ' && vagrant ssh '+ machine.name + '\''
    NSAppleScript.alloc.initWithSource(script).executeAndReturnError(nil)
  end

  def vagrantDir
    dir = @text_url.stringValue
    if File.file?(dir)
      dir = File.dirname(dir)
    end

    dir
  end

  def vagrant(command)
    @task = NSTask.alloc.init
    @pipe = NSPipe.alloc.init

    @commandResult = ''
    @vagrantCommand = command
    script = command.makeScript
    p script

    @logTextView.insertText("\n\n")
    @logTextView.insertText('$ ' + script)
    @logTextView.insertText("\n\n")

    @task.setLaunchPath '/bin/sh'
    @task.setArguments ['-c', script + ' 2>&1']
    @task.setStandardOutput(@pipe)
    @task.launch

    NSNotificationCenter.defaultCenter.addObserver(self,
                                                   selector: 'readVagrantLog:',
                                                   name: NSFileHandleReadCompletionNotification,
                                                   object: nil)

    @pipe.fileHandleForReading.readInBackgroundAndNotify
  end

  def parseVagrantStatus(text)
    list = text.split("\n")
    list.shift
    list.shift

    machines = []
    list.each do |line|
      matches = /(^[0-9a-zA-Z]+)\s+([^\(]+)\(([^\)]+)/.match(line)
      if matches == nil
        break
      end

      machines.push(Machine.new(matches[1], matches[2], matches[3]))
    end

    machines
  end

  def readVagrantLog(notification)
    data = notification.userInfo.valueForKey(NSFileHandleNotificationDataItem)

    text = NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)
    @commandResult += text
    p text

    @logTextView.selectAll(nil)
    wholeRange = @logTextView.selectedRange
    endRange = NSMakeRange(wholeRange.length, 0)
    @logTextView.setSelectedRange(endRange)
    @logTextView.insertText(text)

    @logTextView.scrollRangeToVisible(NSMakeRange(@logTextView.string.length, 0))

    if @task.isRunning
      @pipe.fileHandleForReading.readInBackgroundAndNotify
    else
      NSNotificationCenter.defaultCenter.removeObserver(self)
      @logTextView.insertText("\n")
      @logTextView.insertText('done.')

      if @vagrantCommand.subcommand == 'status'
        @machines = parseVagrantStatus(@commandResult)
        p @machines
        @tableView.reloadData
        toggleButtonsEnable
      else
        vagrant(VagrantCommand.new(@text_url.stringValue, 'status', @machines))
      end
    end
  end

  def numberOfRowsInTableView(aTableView)
    @machines.size
  end

  def tableView(tableView, heightOfRow: row)
    20
  end

  def tableView(tableView, objectValueForTableColumn: tableColumn, row: rowIndex)
    machine = @machines[rowIndex]

    case tableColumn.identifier
      when 'check'
        machine.checked?
      when 'name'
        machine.name
      when 'status'
        machine.status
      when 'provider'
        machine.provider
      when 'ssh'
        tableColumn.dataCell.tap do |cell|
          cell.setEnabled(machine.up?)
        end
      else
        # nop
    end
  end

  def buildTableViewButton
    NSButton.alloc.init.tap do |button|
      button.target = self
      button.bezelStyle = NSRoundedBezelStyle
      button.autoresizingMask = NSViewMinXMargin|NSViewMinYMargin
    end
  end

  def toggleButtonsEnable(isDisabledAll = false)
    if isDisabledAll
      @buttonUp.setEnabled(false)
      @buttonHalt.setEnabled(false)
      @buttonDestroy.setEnabled(false)
      @buttonProvision.setEnabled(false)
      return
    end

    if @machines.count == 0
      @buttonUp.setEnabled(false)
      @buttonHalt.setEnabled(false)
      @buttonDestroy.setEnabled(false)
      @buttonProvision.setEnabled(false)
      return
    end

    checkedMachines = @machines.select { |m| m.checked? }
    if checkedMachines.count == 0
      @buttonUp.setEnabled(false)
      @buttonHalt.setEnabled(false)
      @buttonDestroy.setEnabled(false)
      @buttonProvision.setEnabled(false)
      return
    end

    @buttonDestroy.setEnabled(true)

    if checkedMachines.any? { |m| m.up? }
      @buttonUp.setEnabled(false)
      @buttonHalt.setEnabled(true)
      @buttonProvision.setEnabled(true)
    else
      @buttonUp.setEnabled(true)
      @buttonHalt.setEnabled(false)
      @buttonProvision.setEnabled(false)
    end
  end
end
