# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  ### Re-enable disabled_with buttons for back button ###
  $(document).on 'page:change', ->
    $('.report_button').each ->
      $.rails.enableElement $(this)
      return
    return

  #$('a.group').on 'click', ->
  #  $(this).find( "#details" ).toggle 'slow', ->
  #    return
  #  return