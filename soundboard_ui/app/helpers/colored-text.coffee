import Ember from 'ember'

export default Ember.Helper.extend
  textToHex: Em.inject.service()

  compute: (params) ->
    text = params[0]
    Em.String.htmlSafe "<span style=\"color: #{@get('textToHex').textToHex(text)};\">#{params[0]}</span>"
