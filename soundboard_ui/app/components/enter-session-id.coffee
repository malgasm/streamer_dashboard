import Ember from 'ember'

export default Ember.Component.extend
  session: Em.inject.service()
  actions:
    submitSessionId: ->
      @sendAction('hasInputSessionId', @get('sessionId'))
