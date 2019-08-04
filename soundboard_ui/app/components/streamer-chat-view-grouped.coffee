import moment from 'npm:moment'

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
    @get('store').createRecord('message',
        id: @get('utility').randNum(),
        text: payload.value,
        username: payload.user,
        sentAt: moment()
      )


  messageGroupFromPayload: (payload, message = null) ->
    @get('store').createRecord('messageGroup',
      username: payload.user,
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
    return if @IGNORED_USERS.indexOf(payload.user) != -1
    #{channel, type, user, value}
    # @get('messages').addObject(Em.Object.create(user: payload.user, messageText: payload.value))
    # console.log 'message', Em.Object.create(user: payload.user, messageText: payload.value)
    latestMessageGroup = @get('groupedMessage').latestMessageGroupByUser(payload.user, @get('groupedMessages'))
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
