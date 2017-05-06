# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
class MakeABox.FormHandler
  constructor: (formId) ->
    @form = $('form#' + formId)

  haveSettings: ->
    settings = $.cookie("makeabox-settings");
    return settings ? true: false

  restore: ->
    settings = $.cookie("makeabox-settings");
    if settings
      @form.deserialize(settings);

  showSaveStatusLast: false

  showSaveStatus: ->
    if this.haveSettings()
      $('#restore').disable
    else
      $('#restore').enable

  save: ->
    $.cookie("makeabox-settings", @form.serialize(), {expires: 365, path: '/'});
# $('#save-status').html('Saved');
# $('#save-status').fadeIn 'slow'
# delay 4000, ->
#   this.showSaveStatus()

  clear: (extraClass) ->
    @form.clear(extraClass)

  preventNonNumeric: (e) ->
    char_code = e.which || e.key_code
    char_str = String.fromCharCode(char_code);
    if /[a-zA-Z]/.test(char_str)
      return false

  updatePageSettings: ->
    val = $('select#config_page_size option:selected').text();
    if /Auto/i.test(val)
      $('#page-settings').hide()
    else
      $('#page-settings').show()
    this.showSaveStatus()

    alert = $('.alert-danger')
    if alert
      delay 10000, ->
        alert.fadeOut 'slow'

delay = (ms, func) -> setTimeout func, ms

MakeABox.GA = (label) ->
  if (ga?)
    ga 'send',
      hitType: 'event'
      eventCategory: 'PDF'
      eventAction: 'download'
      eventLabel: label

show_thickness_info = ->
  $('.thickness-info-modal').modal('show')

show_advanced_info = ->
  $('.advanced-info-modal').modal('show')

show_introduction = ->
  $('#introduction-modal').modal('show')

jQuery ->
  $(document).on 'ready', (e) ->
    window.handler = new MakeABox.FormHandler('pdf-generator')
    handler.updatePageSettings()
    seenNotice = $.cookie("had-seen-the-notice")
    if !seenNotice
      delay 200, ->
        $('#one-time-notice').fadeIn "slow"
        $('#introduction-modal').modal('show').fadeIn "fast"
      delay 10000, ->
        $('#one-time-notice').fadeOut "slow"

  $("#config_units_in").on "click", (e) ->
    $('form#pdf-generator').submit();

  $("#config_units_mm").on "click", (e) ->
    $('form#pdf-generator').submit();

  $("#make-pdf").on "click", (e) ->
    MakeABox.GA('Download PDF')
    $('input[name=commit]')[0].value = "true"
    $('form#pdf-generator').submit();

  $('.dont-show-notice').on 'click', (e) ->
    $.cookie("had-seen-the-notice", "yes", {expires: 21, path: '/'})
    $('#one-time-notice').fadeOut "slow"
    $('.modal').fadeOut "slow"

  $('.numeric').on "keypress", (e)->
    return handler.preventNonNumeric(e)

  $('#config_page_size').on 'change', (e) ->
    handler.updatePageSettings()

  $('#clear').on "click", (e) ->
    handler.clear('.box-dimensions')

  $('#save').on "click", (e) ->
    handler.save()
    false

  $('#restore').on "click", (e) ->
    handler.restore()
    false

  $('.logo-image, .logo-name').on 'click', (e) ->
    document.location = '/'
    false

  $('#thickness-info').on 'click', (e) ->
    show_thickness_info()
    false

  $('#introduction').on 'click', (e) ->
    show_introduction()
    false

  $('.advanced-info').on 'click', (e) ->
    show_advanced_info()
    false

  $('.notch-help').on 'click', (e) ->
    show_advanced_info()
    false