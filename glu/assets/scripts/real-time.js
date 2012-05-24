if($.os.ios && $.os.version.match(/^5/)) {
  $('html').addClass('ios');
}

$.os.touch = !(typeof window.ontouchstart === 'undefined');

$(window).on('load', function() {
  return _.defer(function() {
    return window.scrollTo(0, 1);
  });
});

var RealTimeApp = function(opts) {
  this.opts = opts;
  this.views = [];
  this.handlers = {};
  this.connection = new Strophe.Connection(opts.host);

  if('views' in opts)
    opts.views.forEach(RealTimeApp.closure(this.register, this));
};

RealTimeApp.closure = function(fn, scope) {
  return function() {
    return fn.apply(scope, arguments);
  }
};

RealTimeApp.prototype = {
  _subscribe: function(id) {
    var iq = $iq({
      type: 'set',
      to: 'pubsub.xmpp.flow.net',
      id: +new Date()
    }).c('query', {xmlns: 'flow:pubsub'})
      .c('subscribe', {flow: id}).tree();

    this.connection.send(iq);
  },

  _unsubscribe: function(id) {
    var iq = $iq({
      type: 'set',
      to: 'pubsub.xmpp.flow.net',
      id: +new Date()
    }).c('query', {xmlns: 'flow:pubsub'})
      .c('unsubscribe', {flow: id}).tree();

    this.connection.send(iq);
  },

  bind: function(id, callback) {
    var flowId = id.split(':')[1];
    var handler = function(message) {
      this.trigger('message:' + flowId, message.firstChild);
      return true;
    }

    Backbone.Events.bind.call(this, id, callback);
    this.handlers[id] = this.connection.addHandler(
      RealTimeApp.closure(handler, this), null, 'iq', 'result', 'publish-drop-at-' + flowId, 'pubsub.xmpp.flow.net');
    this._subscribe(flowId);
  },

  unbind: function(id, callback) {
    var flowId = id.split(':')[1];
    Backbone.Events.unbind.call(this, id, callback);
    this.connection.deleteHandler(this.handlers[id]);
    this._unsubscribe(flowId);
  },

  trigger: function() {
    Backbone.Events.trigger.apply(this, Array.prototype.slice.call(arguments, 0));
  },

  register: function(view) {
    this.views[view.id] = view.init(this);
  },

  run: function() {
    this.connection.attach(this.opts.jid, this.opts.sid, this.opts.rid);
    this.connection.send($pres());
    this.connection.send($pres({to: 'pubsub.xmpp.flow.net'}));

    var self = this;
    window.setInterval(function() {
      self.connection.send($pres({to: 'pubsub.xmpp.flow.net'}));
    }, 1000 * 10);
  }
};

RealTimeApp.View = function(id) {
  this.id = id;
  this.callback = function(){};
  this.is_initialized = false;
};

RealTimeApp.View.prototype = {
  init: function(app) {
    this.app = app;
    this.is_initialized = true;       
    return this;
  },

  listen: function(id) {
    if(this.is_initialized)
      this.app.bind('message:' + id, RealTimeApp.closure(this.callback, this));
  },

  ignore: function(id) {
    if(this.is_initialized)
      this.app.unbind('message:' + id, RealTimeApp.closure(this.callback, this));
  }
};

RealTimeApp.View.instances = {}
RealTimeApp.View.instances.feed = new RealTimeApp.View('feed');
RealTimeApp.View.instances.feed.callback = function(data) {
  var drop = $(data).find('drop');
  var message = drop.find('message').text();
  var timestamp = parseInt(drop.find('timestamp').text());
  var formattedDate = dateFormat(new Date(timestamp), "dddd h:MM TT");
  var htmlbuf = []; 
  htmlbuf.push('<h3 class="group-header">' + formattedDate + '</h3>');
  htmlbuf.push('<div class="event-group group">');
  htmlbuf.push('<div class="event group-item">');
  htmlbuf.push('<p>' + message + '</p>');
  htmlbuf.push('</div>');
  htmlbuf.push('</div>');

 $('#content').prepend(htmlbuf.join(''));
};

