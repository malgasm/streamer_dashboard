import Ember from 'ember'

export default Ember.Component.extend
  actions:
    valueDidChange: -> @valueDidChange(@element.getElementsByTagName('select')[0].value)
