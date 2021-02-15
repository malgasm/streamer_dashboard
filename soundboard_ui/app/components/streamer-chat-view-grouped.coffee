import Ember from 'ember'
import moment from 'npm:moment'
import jQuery from 'jquery'

export default Ember.Component.extend
  CHAT_SPLIT_THRESHOLD_SECONDS: 120 #seconds
  SUB_ALERT_MESSAGE_TYPES: ['sub', 'subgift', 'multiple_gift_subs', 'resub']
  IGNORED_USERS: ['nightbot','streamelements','streamlabs'] #todo: service this, eventually, pull from yaml
  groupedMessagesSorting: ['lastMessageSentAt:desc']
  messages: []
  groupedMessages: []
  groupedMessage: Em.inject.service()
  classNames: ['streamerChatViewGroupedContainer']

  didInsertElement: ->
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    console.log 'apyload scvg', payload
    if @SUB_ALERT_MESSAGE_TYPES.indexOf(payload.type) != -1
      @newSubEvent(payload)
    else if payload && payload.type == 'message'
      @newMessage(payload)
    else if payload && payload.type == 'channel-points-redemption'
      @showChannelPointsRedemption(payload.params)

  messageFromPayload: (payload) ->
    #todo: create predictibleNumber function based upon textToHex
    #use find_or_create user here instead of always creating a user
    @get('store').createRecord('message',
      id: @get('utility').randNum(),
      text: payload.value,
      emotes: payload.user?.emotes,
      other_emotes: payload.user?.other_emotes,
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
    @get('messages').push(message)

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

  addNewEventGroupFromPayload: (payload, event) ->
    @get('store').createRecord('messageGroup',
      user: payload.params.username
      firstMessageSentAt: moment(),
      lastMessageSentAt: moment(),
      id: @get('utility').randNum(),
      chatEvents: [event]
    )

  newSubEvent: (payload) ->
    @addNewMessageGroupFromPayload(
      value: "#{payload.type} by #{payload.params.username}"
      user: {
        username: 'New Sub/Resub!'
      }
    )
    # newEvent = @get('store').createRecord('chatEvent', jQuery.extend(payload.params, {eventType: payload.type}))
    # #todo: group multiple gift subs and the subsequent sub notifications
    # eventGroup = @addNewEventGroupFromPayload(payload, newEvent)
    # @get('groupedMessages').unshiftObject(eventGroup)

  showChannelPointsRedemption: (params) ->
    @addNewMessageGroupFromPayload(
      value: "#{params.name} by #{params.user}"
      user: {
        username: 'Channel Points Redemption'
      }
    )

  newMessage: (payload) ->
    console.log 'newMessage', payload
    return if @IGNORED_USERS.indexOf(payload.user.username.toLowerCase()) != -1
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
