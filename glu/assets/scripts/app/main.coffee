# Override zepto's default .post and .get to send and receive JSON, and also
# let the callback serve as an errback following node.js callback style

errback = (callback) ->
  return (xhr) ->
    json = if xhr.responseText.match(/^\s*$/) then null else JSON.parse xhr.responseText
    callback and callback.call this, xhr.status, json


succback = (callback) ->
  return (resp) -> callback and callback.call this, false, resp


ajaxReq = (type, url, data, callback) ->
  if $.isFunction data
    callback = data
    data = null

  if type != 'GET'
    data = if !data then '' else JSON.stringify data

  $.ajax
    contentType : if type is 'GET' then 'application/x-www-form-urlencoded' else 'application/json'
    dataType    : 'json'
    type        : type
    url         : url
    data        : data
    success     : succback callback
    error       : errback callback


$.post = (url, data, callback) -> ajaxReq 'POST', url, data, callback
$.get  = (url, data, callback) -> ajaxReq 'GET',  url, data, callback


# Add classes for css hooks
if $.os.ios and $.os.version.match /^5/
  $('html').addClass 'ios'

# Zepto touch device detection
$.os.touch = !(typeof window.ontouchstart is 'undefined')

# Hide navigation bar
$(window).on "load", -> _.defer -> window.scrollTo 0, 1
