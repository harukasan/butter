class PreferencesController < NSWindowController
  extend IB

  NotificationModeKey = 'notificationMode'

  outlet :button, NSButton
  outlet :notification_popup, NSButton

  def init
    initWithWindowNibName('PreferencesWindow')
  end

  def windowDidLoad
    user_defaults = NSUserDefaults.standardUserDefaults

    mode = user_defaults.integerForKey NotificationModeKey
    @notification_popup.selectItemWithTag mode
  end

  def closeWindow(sender)
    user_defaults = NSUserDefaults.standardUserDefaults

    mode = @notification_popup.selectedTag
    user_defaults.setInteger mode, forKey: NotificationModeKey

    NSApplication.sharedApplication.endSheet window
  end

  def sheetDidEnd(sheet)
    sheet.orderOut self
  end
end
