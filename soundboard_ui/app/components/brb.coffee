import Ember from 'ember'

export default Ember.Component.extend
  streamSession: Em.inject.service('stream-session-websocket')

  didReceiveStreamAction: (payload) ->
    console.log 'didReceiveStreamAction brb', payload
    if payload.type && payload.type == 'change-brb-direction'
      @changeDirection(payload.value)

  changeDirection: (direction) ->
    return if @get('isDestroyed')
    console.log 'changing direction to', direction
    @setProperties
      xDir: direction
      yDir: direction
    @notifyPropertyChange('xDir')
    @notifyPropertyChange('yDir')
