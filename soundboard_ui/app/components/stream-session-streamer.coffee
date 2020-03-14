import Ember from 'ember'

export default Ember.Component.extend(
  store: Em.inject.service()
  didInsertElement: ->
    window.z = @get('store')
)
