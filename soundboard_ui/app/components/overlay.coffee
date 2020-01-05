import Ember from 'ember'

export default Ember.Component.extend
  streamSession: Em.inject.service('stream-session-websocket')
  animation: null
  brbImage: null

  actions:
    animationDidFinish: ->
      console.log 'animation complete.'

  didInsertElement: ->
    @get('streamSession').listenForStreamSessionEvents(@didReceiveStreamAction.bind(@))
    window.b = @

  didReceiveStreamAction: (payload) ->
    console.log 'didReceiveStreamAction overlay', payload
    if payload.type && payload.type == 'brb-toggle'
      @toggleBrb(payload.value)
    else if payload.type && payload.type == 'set-brb-image'
      @setBrbImage(payload.value)

  toggleBrb: (brb) -> @set('brb', brb)

  setBrbImage: (image) ->
    @set('brbImage', image)
    console.log 'successfully set brb image to ', @get('brbImage')
