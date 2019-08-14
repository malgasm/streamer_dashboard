import Ember from 'ember'

export default Ember.Component.extend
  classNames: ['onoffbutton']
  click: ->
    @onClick()
