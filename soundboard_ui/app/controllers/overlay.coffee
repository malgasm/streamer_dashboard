import Ember from 'ember'

export default Ember.Controller.extend
  websocket: Em.inject.service()
  messageBus: Em.inject.service()
  session: Em.inject.service()
  #todo: this entire thing needs to work differently, based upon how OBS studio handles the browser source
  #it should write a static page and that static page should be referenced by OBS
  init: ->
    @_super()
    @startWebsocketConnection()
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction.bind(@))

  didReceiveStreamAction: (payload) ->
    console.log 'dRSA overlay', payload
    if payload.type && payload.type == 'brb-toggle'
      @set('brb', payload.value)

  startWebsocketConnection: ->
    if @get('session.hasCurrentSession') && @get('session.hasCurrentRole')
      @get('websocket').connect(@get('session').getCurrentSession())
