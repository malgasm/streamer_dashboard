import Ember from 'ember'

export default Ember.Component.extend
  websocket: Em.inject.service()
  brb: false
  actions:
    didToggleBrb: (brb) ->
      @get('websocket').sendMessage('brb-toggle', brb)

    didChangeBrbEmote: (emote) ->
      @get('websocket').sendMessage('set-brb-image', emote )
