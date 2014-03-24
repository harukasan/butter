class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu

    window = NSWindow.alloc.initWithContentRect([[240, 180], [800, 500]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @main = MainWindowController.new(window)
  end

  def applicationShouldTerminateAfterLastWindowClosed(app)
    return false
  end

  def applicationShouldHandleReopen(app, hasVisibleWindows:isVisible)
    @main.window.setIsVisible true
    return true
  end

  def openPreferences(menuItem)
    @preferences = PreferencesController.alloc.init
    NSApplication.sharedApplication.beginSheet @preferences.window,
      modalForWindow: @main.window,
      modalDelegate: @preferences,
      didEndSelector: "sheetDidEnd:",
      contextInfo: nil
  end
end


