import Ember from 'ember'
import { uniq } from '@ember/object/computed'

export default Ember.Component.extend
  messages: []

  didInsertElement: ->
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    console.log 'apyload', payload
    if payload && payload.type == 'message'
      @get('messages').addObject(Em.Object.create(user: payload.user, messageText: payload.value))
      console.log 'message', Em.Object.create(user: payload.user, messageText: payload.value)

  uniqueUsersWithMessageCounts: Em.computed('messages.length', ->
    @get('messages').uniqBy('user.username').map (message) =>
      Em.Object.create(
        username: message.get('user.username'),
        messageCount: @get('messages').filter((msg) ->
          message.get('user.username') == msg.get('user.username')
        ).get('length')
      )
  )

  sortedUsersWithCounts: Em.computed('uniqueUsersWithMessageCounts', ->
    @get('uniqueUsersWithMessageCounts').sortBy('messageCount').reverseObjects()
  )

