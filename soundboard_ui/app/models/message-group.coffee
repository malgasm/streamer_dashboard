import DS from 'ember-data'

export default DS.Model.extend
  messages:            DS.hasMany('message')
  chatEvents:          DS.hasMany('chatEvent')
  user:                DS.belongsTo('user')
  firstMessageSentAt:  DS.attr('date')
  lastMessageSentAt:   DS.attr('date')

  hasEvents: Em.computed('chatEvents.@each', ->
    @get('chatEvents.length') > 0
  )

  firstMessageTimestamp: Em.computed('firstMessageSentAt', ->
    @get('firstMessageSentAt').format('h:mma').toString()
  )
  lastMessageTimestamp: Em.computed('lastMessageSentAt', ->
    @get('lastMessageSentAt').format('h:mma').toString()
  )
