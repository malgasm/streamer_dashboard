import DS from 'ember-data'

export default DS.Model.extend
  text:          DS.attr('string')
  username:      DS.attr('string')
  sentAt:        DS.attr('date')
  messageGroup:  DS.belongsTo('message-group')
