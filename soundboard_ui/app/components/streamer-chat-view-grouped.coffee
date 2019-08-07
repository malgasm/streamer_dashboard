import moment from 'npm:moment'
import jQuery from 'jquery'

export default Ember.Component.extend
  CHAT_SPLIT_THRESHOLD_SECONDS: 120 #seconds
  groupedMessagesSorting: ['lastMessageSentAt:desc']
  messages: []
  groupedMessages: []
  groupedMessage: Em.inject.service()
  classNames: ['streamerChatViewGroupedContainer']
  IGNORED_USERS: ['nightbot','streamelements','streamlabs'] #todo: service this, eventually, pull from yaml

  didInsertElement: ->
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    console.log 'apyload', payload
    if payload && payload.type == 'message'
      @newMessage(payload)

  messageFromPayload: (payload) ->
    console.log 'user', payload.user
    #todo: create predictibleNumber function based upon textToHex
    #use find_or_create user here instead of always creating a user
    @get('store').createRecord('message',
      id: @get('utility').randNum(),
      text: payload.value,
      user: @get('store').createRecord('user', jQuery.extend(payload.user, {id: @get('utility').randNum()}))
      sentAt: moment()
    )

  messageGroupFromPayload: (payload, message = null) ->
    @get('store').createRecord('messageGroup',
      user: @get('store').createRecord('user', jQuery.extend(payload.user, {id: @get('utility').randNum()})),
      firstMessageSentAt: moment(),
      lastMessageSentAt: moment(),
      id: @get('utility').randNum(),
    )

  addMessageToGroup: (group, message) ->
    group.set('lastMessageSentAt', moment())
    group.get('messages').addObject(message)

  groupedMessagesSortedByLastMessage: Em.computed.sort('groupedMessages.@each.lastMessageSentAt', (a, b) ->
    if moment(a.get('lastMessageSentAt')) > moment(b.get('lastMessageSentAt'))
      -1
    else if moment(a.get('lastMessageSentAt')) < moment(b.get('lastMessageSentAt'))
      1
    else
      0
  )

  addNewMessageGroupFromPayload: (payload) ->
    message = @messageFromPayload(payload)
    messageGroup = @messageGroupFromPayload(payload)
    @addMessageToGroup(messageGroup, message)
    @get('groupedMessages').unshiftObject(messageGroup)

  newMessage: (payload) ->
    console.log 'newMessage', payload
    return if @IGNORED_USERS.indexOf(payload.user.username) != -1
    latestMessageGroup = @get('groupedMessage').latestMessageGroupByUser(payload.user.username, @get('groupedMessages'))
    console.log 'latestMessageGroup', JSON.stringify(latestMessageGroup)
    if latestMessageGroup && latestMessageGroup.get('firstMessageSentAt')
      if moment().diff(latestMessageGroup.get('firstMessageSentAt'), 'seconds') > @CHAT_SPLIT_THRESHOLD_SECONDS
        console.log 'CHAT_SPLIT_THRESHOLD reached. creating a new message group.'
        @addNewMessageGroupFromPayload(payload)
      else
        console.log 'CHAT_SPLIT_THRESHOLD not reached. appending message.'
        @addMessageToGroup(latestMessageGroup, @messageFromPayload(payload))
    else
      @addNewMessageGroupFromPayload(payload)
      console.log 'no latest message found. creating a new one.'

    window.g = @get('groupedMessages')
