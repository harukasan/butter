class AppDelegate
  def buildMenu
    @mainMenu = NSMenu.new

    appName = NSBundle.mainBundle.infoDictionary['CFBundleName']
    addMenu(appName) do
      addItemWithTitle("About #{appName}", action: 'orderFrontStandardAboutPanel:', keyEquivalent: '')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Preferences', action: 'openPreferences:', keyEquivalent: ',')
      addItem(NSMenuItem.separatorItem)
      servicesItem = addItemWithTitle('Services', action: nil, keyEquivalent: '')
      NSApp.servicesMenu = servicesItem.submenu = NSMenu.new
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle("Hide #{appName}", action: 'hide:', keyEquivalent: 'h')
      item = addItemWithTitle('Hide Others', action: 'hideOtherApplications:', keyEquivalent: 'H')
      item.keyEquivalentModifierMask = NSCommandKeyMask|NSAlternateKeyMask
      addItemWithTitle('Show All', action: 'unhideAllApplications:', keyEquivalent: '')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle("Quit #{appName}", action: 'terminate:', keyEquivalent: 'q')
    end

    addMenu('File') do
      addItemWithTitle('Close', action: 'performClose:', keyEquivalent: 'w')
    end

    addMenu('Edit') do
      addItemWithTitle('Undo', action: 'undo:', keyEquivalent: 'z')
      addItemWithTitle('Redo', action: 'redo:', keyEquivalent: 'Z')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Cut', action: 'cut:', keyEquivalent: 'x')
      addItemWithTitle('Copy', action: 'copy:', keyEquivalent: 'c')
      addItemWithTitle('Paste', action: 'paste:', keyEquivalent: 'v')
      item = addItemWithTitle('Paste and Match Style', action: 'pasteAsPlainText:', keyEquivalent: 'V')
      item.keyEquivalentModifierMask = NSCommandKeyMask|NSAlternateKeyMask
      addItemWithTitle('Delete', action: 'delete:', keyEquivalent: '')
      addItemWithTitle('Select All', action: 'selectAll:', keyEquivalent: 'a')
    end

    addMenu('View') do
      item = addItemWithTitle('Show Toolbar', action: 'toggleToolbarShown:', keyEquivalent: 't')
      item.keyEquivalentModifierMask = NSCommandKeyMask|NSAlternateKeyMask
      addItemWithTitle('Customize Toolbar…', action: 'runToolbarCustomizationPalette:', keyEquivalent: '')
    end

    NSApp.windowsMenu = addMenu('Window') do
      addItemWithTitle('Minimize', action: 'performMiniaturize:', keyEquivalent: 'm')
      addItemWithTitle('Zoom', action: 'performZoom:', keyEquivalent: '')
      addItemWithTitle('Enter Full Screen', action: 'toggelFullScreen:', keyEquivalent: '')
      addItem(NSMenuItem.separatorItem)
      addItemWithTitle('Bring All To Front', action: 'arrangeInFront:', keyEquivalent: '')
    end.menu

    NSApp.helpMenu = addMenu('Help') do
      addItemWithTitle("#{appName} Help", action: 'showHelp:', keyEquivalent: '?')
    end.menu

    NSApp.mainMenu = @mainMenu
  end

  private

  def addMenu(title, &b)
    item = createMenu(title, &b)
    @mainMenu.addItem item
    item
  end

  def createMenu(title, &b)
    menu = NSMenu.alloc.initWithTitle(title)
    menu.instance_eval(&b) if b
    item = NSMenuItem.alloc.initWithTitle(title, action: nil, keyEquivalent: '')
    item.submenu = menu
    item
  end
end
