import DS from 'ember-data'

export default DS.Model.extend
  eventType:           DS.attr('string')
  messageGroup:        DS.belongsTo('message-group')
  gift_sub_recipient:  DS.attr('string')
  username:            DS.attr('string')
  bits:                DS.attr('number')
  sub_months:          DS.attr('number')
  sub_streak:          DS.attr('number')
  sub_tier:            DS.attr('number')
  gift_sub_quantity:   DS.attr('number')

  isGiftSub: Em.computed('eventType', -> @get('eventType') == 'subgift' )
  isMultipleGiftSub: Em.computed('eventType', -> @get('eventType') == 'multiple_gift_subs' )
  isSub: Em.computed('eventType', -> @get('eventType') == 'sub' )
  isResub: Em.computed('eventType', -> @get('eventType') == 'resub' )
