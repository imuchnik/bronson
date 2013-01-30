throbberImg = '<img src="/bronson/admin/throbber" alt="">'


class Button
  constructor: (element, @clickCallback) ->
    @container = $ element
    @container.click @click

  click: =>
    return if @container.hasClass 'disabled'
    @container.addClass 'disabled'
    @clickCallback.call @


addBenchmarkFrames = (numFrames, callback) ->
  iframe = $ "<iframe class='benchmark' src='/bronson/admin/frame?u#{numFrames}' scrolling='no'>"
  $('.benchmark-frames').append iframe
  iframe.load ->
    if numFrames > 0
      addBenchmarkFrames numFrames-1, callback
    else
      callback()


$ ->
  ping = new Button '.ping', ->
    @container.html throbberImg
    setTimeout =>
      @container.parent().children('span').text('200ms')
      @container.removeClass 'disabled'
      @container.text 'Ping'
    , 2000


  startBenchmark = new Button '.start-benchmark', ->
    $('.benchmark-status-message').html "#{throbberImg} Loading worker frames..."
    numWorkers = parseInt($('.num-workers').val()) - 1
    addBenchmarkFrames numWorkers, =>
      @container.text 'Add More Workers'
      @container.removeClass 'disabled'
      $('.benchmark-status-message').html "#{throbberImg} Testing Bronson..."


  $('.navbar ul.nav a').click ->
    $('.page,.navbar ul.nav li').removeClass 'active'
    $(@).parent().addClass 'active'
    $($(@).attr('href')).addClass 'active'
