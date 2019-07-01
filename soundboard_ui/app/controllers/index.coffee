import Ember from 'ember'

export default Ember.Controller.extend
  session: Em.inject.service()

  actions:
    hasInputSessionId: (sessionId) ->
      console.log 'sid', sessionId
      @get('session').setCurrentSession(sessionId)

    clearSession: ->
      @get('session').clearCurrentSession()

    clearRole: ->
      @get('session').clearCurrentRole()

  init: ->
    @get('session').getCurrentSession()
    @get('session').getCurrentRole()

  componentForRole: Em.computed('session.currentRole', ->
    "stream-session-#{@get('session.currentRole')}"
  )
