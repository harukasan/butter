def debug(message)
  p message if BubbleWrap.debug?
end

class AppDelegate
  def applicationDidFinishLaunching(notification)
    debug "#{App.name} (#{App.documents_path})"
    buildMenu

    window = NSWindow.alloc.initWithContentRect([[240, 180], [800, 500]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @controller = MainWindowController.new(window)
    @window = @controller.window
  end

  def applicationShouldTerminateAfterLastWindowClosed(app)
    return false
  end

  def applicationShouldHandleReopen(app, hasVisibleWindows:isVisible)
    @window.setIsVisible true
    return true
  end

end


