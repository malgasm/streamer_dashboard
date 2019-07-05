import Ember from 'ember'

export default Ember.Component.extend
  messageBus: Em.inject.service()
  utility: Em.inject.service()
  events: []

  didInsertElement: ->
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    @get('events').addObject(text: "key: #{payload.type}, value: #{payload.value}")
