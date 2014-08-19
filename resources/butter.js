(function(){
  var onMessageCreated = function(data){
    var notify = false;
    var mode = window.butter.notificationMode();
    if (mode == "all") {
      notify = true;
    } else if (mode == "mention") {
      if (data.message.mentions.indexOf(parseInt(window.Idobata.user.id)) >= 0) {
        notify = true;
      }
    }
    if (notify) {
      butter.notify(JSON.stringify(data.message));
    }
  };

  var onUnreadCountUpdated = function() {
    var totalUnreadCount = this.get('rooms').reduce(function(acc, room) {
      return acc + room.get('unreadMessagesCount');
    }, 0);
    window.butter.setBadge(totalUnreadCount);
  }

  var bindEvent = function(){
    if (!window.Idobata.pusher) {
      return false;
    }
    if (!window.Idobata.user) {
      return false;
    }
    window.Idobata.pusher.bind('message_created', onMessageCreated);
    window.Idobata.user.addObserver('rooms.@each.unreadMessagesCount', onUnreadCountUpdated);
    onUnreadCountUpdated.apply(window.Idobata.user);

    return true;
  };

  setTimeout(function setBind(){
    if (!bindEvent()) {
      setTimeout(setBind, 100);
    }
  }, 100);
})();
