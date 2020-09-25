import Ember from 'ember'

export default Ember.Service.extend
  messageBus: Em.inject.service()
  session: Em.inject.service()
  websocket: Em.inject.service()

  listenForStreamSessionEvents: (callback) ->
    @startWebsocketConnection()
    @get('messageBus').subscribe('stream_action', @, callback)

  startWebsocketConnection: ->
    if @get('session.hasCurrentSession') && @get('session.hasCurrentRole')
      @get('websocket').connect(@get('session').getCurrentSession()).then =>
