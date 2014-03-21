class MainWindowController < NSWindowController
  HOST = "idobata.io"

  def self.isSelectorExcludedFromWebScript(selector)
    case selector.to_s
    when "notify:"
      return false
    end
    return true
  end

  def self.webScriptNameForSelector(selector)
    case selector.to_s
    when "notify:"
      return "notify"
    end
  end

  def initialize(window)
    initWithWindow window
    initWindow
    initWebView

    self
  end

  def initWindow
    window.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    window.orderFrontRegardless
    window.center
    window.setOneShot true
    window.setReleasedWhenClosed false
  end

  def initWebView
    rect =NSMakeRect(0, 0, window.contentView.frame.size.width, window.contentView.frame.size.height)
    @web_view = WebView.alloc.initWithFrame rect
    @web_view.setAutoresizingMask(NSViewMinXMargin|NSViewMaxXMargin|NSViewMinYMargin|NSViewMaxYMargin|NSViewWidthSizable|NSViewHeightSizable)
    window.contentView.addSubview @web_view

    @web_view.setFrameLoadDelegate self
    @web_view.setUIDelegate self
    @web_view.setPolicyDelegate self

    url = NSURL.URLWithString "https://idobata.io/users/sign_in"
    request = NSURLRequest.requestWithURL url
    @web_view.mainFrame.loadRequest request
  end

  def notify(data)
    data = BW::JSON.parse data.to_s.dataUsingEncoding(NSUTF8StringEncoding)

    notification = NSUserNotification.alloc.init
    notification.title = data['sender_name']
    notification.informativeText = data['body_plain']
    notification.soundName = NSUserNotificationDefaultSoundName
    notification.userInfo = data

    sender_icon_url = data['sender_icon_url']
    if sender_icon_url.length > 0
      notification.contentImage = fetchIconImage sender_icon_url
    end

    center = NSUserNotificationCenter.defaultUserNotificationCenter
    center.delegate = self
    center.deliverNotification notification
  end

  def fetchIconImage(url)
    icon_size = NSMakeSize(48, 48)
    if url.substringToIndex(1) == "/"
      url = "https://#{HOST}#{url}"
    end
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
    debug "locateToRoom"
    window_object = @web_view.windowScriptObject
    window_object.evaluateWebScript <<-CODE
      location.href = "#/organization/#{organization}/room/#{room_name}";
    CODE
    @web_view.display
  end

  def webView(sender, didFinishLoadForFrame:frame)
    window_object = sender.windowScriptObject
    window_object.evaluateWebScript <<-CODE
      setTimeout(function(){
        window.Idobata.pusher.bind('message_created', function(data){
          if (data.message.mentions.indexOf(parseInt(window.Idobata.user.id)) >= 0) {
            butter.notify(JSON.stringify(data.message));
          }
        });
      }, 1000);
    CODE
  end

  def webView(sender, didClearWindowObject:window_object, forFrame:frame)
    debug "webView:didClearWindowObject:forFrame"
    window_object.setValue self, forKey:"butter"
  end

  # requested a new window
  def webView(sender, createWebViewWithRequest:request)
    debug "webview:createWebViewWithRequest"
    return sender # return own window
  end

  def webView(sender, decidePolicyForNavigationAction:info, request:request, frame:frame, decisionListener:listener)
    debug "webview:decidePolicyForNewWindowAction"
    host = request.URL.host
    return listener.use if !host or host == HOST

    NSWorkspace.sharedWorkspace.openURL request.URL
    listener.ignore
  end

  def webView(sender, decidePolicyForNewWindowAction:info, request:request, frame:frame, decisionListener:listener)
    debug "webview:decidePolicyForNewWindowAction"
    NSWorkspace.sharedWorkspace.openURL request.URL
  end

  def webView(sender, runJavaScriptAlertPanelWithMessage:message, initiatedByFrame:frame)
    NSRunAlertPanel "alert", message, "OK", nil, nil
  end

  def webView(sender, runOpenPanelForFileButtonWithResultListener:listener)
    dialog = NSOpenPanel.openPanel
    dialog.setCanChooseFiles true
    dialog.setCanChooseDirectories false

    dialog.beginSheetModalForWindow window, completionHandler: Proc.new {|result|
      files = dialog.filenames
      break listener.cancel unless files.size > 0
      filename = files.objectAtIndex 0
      listener.chooseFilename filename
    }
  end

  def userNotificationCenter(center, didActivateNotification:notification)
    debug "userNotificationCenter:didActivateNotification"
    info = notification.userInfo
    locateToRoom info["organization_slug"], info["room_name"]
  end
end
