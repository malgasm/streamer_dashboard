import Ember from 'ember'

export default Ember.Component.extend
  brb: false
  actions:
    didToggleBrb: ->
      @toggleProperty('brb')
      @didToggleBrb(@get('brb'))
