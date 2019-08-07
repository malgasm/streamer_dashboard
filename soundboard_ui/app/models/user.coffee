import DS from 'ember-data'

export default DS.Model.extend
  isMod:     DS.attr('boolean')
  isSub:     DS.attr('boolean')
  username:  DS.attr('string')
  messages:  DS.hasMany('message')
