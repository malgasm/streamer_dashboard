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
    @get('messages').uniqBy('user').map (message) =>
      console.log 'user', message.user
      window.b = @get('messages')
      console.log @get('messages').filterBy('user', message.user).get('length')

      Em.Object.create(
        username: message.user,
        messageCount: @get('messages').filterBy('user', message.user).get('length')
      )
  )

  sortedUsersWithCounts: Em.computed('uniqueUsersWithMessageCounts', ->
    @get('uniqueUsersWithMessageCounts').sortBy('messageCount').reverseObjects()
  )

