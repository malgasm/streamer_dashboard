import Ember from 'ember'

export default Ember.Service.extend
  latestMessageGroupByUser: (username, groupedMessages) ->
    groupedMessages.filterBy('hasEvents', false).filter((groupedMessage) =>
      groupedMessage.get('user.username').toLowerCase() == username.toLowerCase()
    ).sortBy('firstMessageSentAt').get('firstObject')
