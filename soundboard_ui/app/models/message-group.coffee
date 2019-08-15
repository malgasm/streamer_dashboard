import DS from 'ember-data'

export default DS.Model.extend
  messages:            DS.hasMany('message')
  user:                DS.belongsTo('user')
  firstMessageSentAt:  DS.attr('date')
  lastMessageSentAt:   DS.attr('date')

  firstMessageTimestamp: Em.computed('firstMessageSentAt', ->
    @get('firstMessageSentAt').format('h:mma').toString()
  )
  lastMessageTimestamp: Em.computed('lastMessageSentAt', ->
    @get('lastMessageSentAt').format('h:mma').toString()
  )
