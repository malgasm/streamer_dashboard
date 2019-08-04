import DS from 'ember-data'

export default DS.Model.extend
  messages:             DS.hasMany('message')
  username:            DS.attr('string')
  firstMessageSentAt:  DS.attr('date')
  lastMessageSentAt:  DS.attr('date')

  firstMessageTimestamp: Em.computed('firstMessageSentAt', ->
    @get('firstMessageSentAt').format('H:mma').toString()
  )
  lastMessageTimestamp: Em.computed('lastMessageSentAt', ->
    @get('lastMessageSentAt').format('H:mma').toString()
  )
