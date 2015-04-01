class MainController < NSWindowController
  Host = "idobata.io"
  NotificationModeKey = 'notificationMode'

  def self.isSelectorExcludedFromWebScript(selector)
    case selector.to_s
    when "notify:"
      return false
    when "notificationMode"
      return false
    when "setBadge:"
      return false
    else
      return true
    end
  end

  def self.webScriptNameForSelector(selector)
    case selector.to_s
    when "notify:"
      return "notify"
    when "notificationMode"
      return "notificationMode"
    when "setBadge:"
      return "setBadge"
    end
  end

  def initialize(window)
    initWithWindow window
    window.tap do |w|
      w.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
      w.orderFrontRegardless
      w.center
      w.setOneShot true
      w.setReleasedWhenClosed false
      w.setCollectionBehavior NSWindowCollectionBehaviorFullScreenPrimary
    end
    setWindowFrameAutosaveName "MainWindow"
    initWebView

    self
  end

  def initWebView
    rect = NSMakeRect(0, 0, window.contentView.frame.size.width, window.contentView.frame.size.height)
    @web_view = WebView.alloc.initWithFrame rect
    @web_view.setAutoresizingMask(NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin|NSViewWidthSizable|NSViewHeightSizable)
    window.contentView.addSubview @web_view

    @web_view.setFrameLoadDelegate self
    @web_view.setUIDelegate self
    @web_view.setPolicyDelegate self

    url = NSURL.URLWithString "https://idobata.io/#/"
    request = NSURLRequest.requestWithURL url
    @web_view.mainFrame.loadRequest request
  end

  def notify(data)
    data = BW::JSON.parse data.to_s.dataUsingEncoding(NSUTF8StringEncoding)

    notification = NSUserNotification.alloc.init.tap do |n|
      n.title = "#{data['sender_name']} \u25b8 #{data['room_name']}"
      n.informativeText = data['body_plain']
      n.soundName = NSUserNotificationDefaultSoundName
      keys = [
        "organization_slug",
        "room_name",
      ]
      n.userInfo = data.select {|key, val| keys.include? key }
    end

    sender_icon_url = data['sender_icon_url']
    if sender_icon_url.length > 0
      notification.contentImage = fetchIconImage sender_icon_url
    end

    NSUserNotificationCenter.defaultUserNotificationCenter.tap do |center|
      center.delegate = self
      center.deliverNotification notification
    end
  end

  def notificationMode
    user_defaults = NSUserDefaults.standardUserDefaults
    mode = user_defaults.integerForKey NotificationModeKey

    return case mode
    when 1 then "all"
    when 2 then "mention"
    when 3 then "off"
    end
  end

  def setBadge(label)
    label = (label.to_i == 0) ? "" : label.to_i.to_s
    NSApplication.sharedApplication.dockTile.setBadgeLabel label
  end

  def fetchIconImage(url)
    icon_size = NSMakeSize(48, 48)
    url = "https://#{Host}#{url}" if url.substringToIndex(1) == "/"
    raw_image = NSImage.alloc.initWithContentsOfURL NSURL.URLWithString(url)
    image = NSImage.alloc.initWithSize icon_size

    image.lockFocus
    raw_image.setScalesWhenResized true
    raw_image.setSize icon_size
    raw_image.drawAtPoint NSZeroPoint, fromRect: NSMakeRect(0, 0, 48, 48), operation:NSCompositeCopy, fraction: 1
    image.unlockFocus

    return image
  end

  def locateToRoom(organization, room_name)
    window_object = @web_view.windowScriptObject
    window_object.evaluateWebScript <<-CODE
      location.href = "#/organization/#{organization}/room/#{room_name}";
    CODE
    @web_view.display
  end

  # called when frame loading finished
  def webView(sender, didFinishLoadForFrame:frame)
    sender.windowScriptObject.evaluateWebScript <<-CODE
      (function(){
        var onMessageCreated = function(user) {
          return function(data){
            var notify = false;
            var mode = window.butter.notificationMode();
            if (mode == "all") {
              notify = true;
            } else if (mode == "mention") {
              if (data.message.mentions.indexOf(parseInt(user.get('id'))) >= 0) {
                notify = true;
              }
            }
            if (notify) {
              butter.notify(JSON.stringify(data.message));
            }
          };
        };

        var onUnreadCountUpdated = function() {
          window.butter.setBadge(this.get('totalUnreadMessagesCount'));
        }

        window.addEventListener('ready.idobata', function(e) {
          var container = e.detail.container;

          var pusher = container.lookup('pusher:main');
          var user   = container.lookup('service:session').get('user');

          pusher.bind('message:created', onMessageCreated(user));
          user.addObserver('totalUnreadMessagesCount', onUnreadCountUpdated);
          onUnreadCountUpdated.apply(user);
        });
      })();
    CODE
  end

  # called when window object is cleared
  def webView(sender, didClearWindowObject:window_object, forFrame:frame)
    window_object.setValue self, forKey:"butter"
  end

  # requested a new window
  def webView(sender, createWebViewWithRequest:request)
    return sender # return own window
  end

  def webView(sender, decidePolicyForNavigationAction:info, request:request, frame:frame, decisionListener:listener)
    host = request.URL.host

    # ignore on navigate to local file (idobata.io is not supported local file link)
    return listener.ignore if request.URL.isFileURL

    return listener.use if !host or host == Host

    NSWorkspace.sharedWorkspace.openURL request.URL
    listener.ignore
  end

  def webView(sender, decidePolicyForNewWindowAction:info, request:request, frame:frame, decisionListener:listener)
    NSWorkspace.sharedWorkspace.openURL request.URL
  end

  def webView(sender, runJavaScriptAlertPanelWithMessage:message, initiatedByFrame:frame)
    puts "ALERT: #{message}"
    NSRunAlertPanel "alert", message, "OK", nil, nil
  end

  def webView(sender, runJavaScriptConfirmPanelWithMessage:message, initiatedByFrame:frame)
    result = NSRunAlertPanel "confirm", message, "OK", "Cancel", nil
    return (result == NSAlertDefaultReturn)
  end

  def webView(sender, runOpenPanelForFileButtonWithResultListener:listener)
    dialog = NSOpenPanel.openPanel
    dialog.setCanChooseFiles true
    dialog.setCanChooseDirectories false

    dialog.beginSheetModalForWindow window, completionHandler: Proc.new {|result|
      files = dialog.filenames
      break listener.cancel unless result == NSOKButton
      break listener.cancel unless files.size > 0
      filename = files.objectAtIndex 0
      listener.chooseFilename filename
    }
  end

  def userNotificationCenter(center, shouldPresentNotification:notification)
    return true
  end

  def userNotificationCenter(center, didActivateNotification:notification)
    info = notification.userInfo
    locateToRoom info["organization_slug"], info["room_name"]
    center.removeDeliveredNotification notification
  end
end
