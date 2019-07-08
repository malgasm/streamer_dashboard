import Ember from 'ember'

export default Ember.Component.extend
  messageBus: Em.inject.service()
  utility: Em.inject.service()
  events: []

  didInsertElement: ->
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    console.log 'dRSA', payload
    @get('events').unshiftObject(Em.Object.create(payload))
