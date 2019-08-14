import Ember from 'ember'

export default Ember.Component.extend
  websocket: Em.inject.service()
  brb: false
  actions:
    didToggleBrb: ->
      @toggleProperty('brb')
      @get('websocket').sendMessage('brb-toggle', @get('brb'))
