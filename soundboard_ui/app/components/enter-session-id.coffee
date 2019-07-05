import Ember from 'ember'

export default Ember.Component.extend
  session: Em.inject.service()

  actions:
    clearSession: ->
      @clearSession()
      @set('sessionId', null)

    submitSessionId: ->
      @hasInputSessionId(@get('sessionId'))
