import DS from 'ember-data'
import moment from 'npm:moment'

export default DS.Model.extend
  text:          DS.attr('string')
  username:      DS.attr('string')
  sentAt:        DS.attr('date')
  messageGroup:  DS.belongsTo('message-group')

  timestamp: Em.computed('sentAt', ->
    moment(@get('sentAt')).format('H:mma')
  )
