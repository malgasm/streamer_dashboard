import Ember from 'ember'

export default Ember.Service.extend
  latestMessageGroupByUser: (username, groupedMessages) ->
    groupedMessages.filterBy('username', username).sortBy('firstMessageSentAt').get('firstObject')
