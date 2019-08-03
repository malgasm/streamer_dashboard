import Ember from 'ember'

export default Ember.Component.extend
  events: []

  didInsertElement: ->
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    console.log 'dRSA', payload
    if payload.type && payload.type == 'message'
      @get('events').unshiftObject(Em.Object.create(payload))
