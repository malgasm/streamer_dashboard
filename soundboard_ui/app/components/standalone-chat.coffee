import Ember from 'ember'

export default Ember.Component.extend
  chat: Ember.inject.service()
  messageBus: Ember.inject.service()

  didInsertElement: ->
    @get('chat').getLatestChat().then (messages) =>
      messages.forEach (message) =>
        console.log 'msg', JSON.stringify(message)

        @get('messageBus').publish('stream_action', {
          type: "message",
          user: {
            username: message.get('user')
          },
          channel: "",
          value: message.get('text')
        })
