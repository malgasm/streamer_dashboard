import DS from 'ember-data'

export default DS.Model.extend
  messages:             DS.hasMany('message')
  username:            DS.attr('string')
  firstMessageSentAt:  DS.attr('date')
  lastMessageSentAt:  DS.attr('date')
