import Ember from 'ember'

export default Ember.Component.extend
  session: Em.inject.service()
  websocket: Em.inject.service()

  actions:
    hasInputSessionId: (sessionId) ->
      console.log 'sid', sessionId
      @get('session').setCurrentSession(sessionId)

    clearSession: ->
      @get('session').clearCurrentSession()

    clearRole: ->
      @get('session').clearCurrentRole()

    setRole: (newRole) ->
      @get('session').setCurrentRole(newRole)

  didInsertElement: ->
    @get('session').getCurrentSession()
    @get('session').getCurrentRole()
    @startWebsocketConnection()

  startWebsocketConnection: ->
    if @get('hasSessionAndRole')
      @get('websocket').connect(@get('session').getCurrentSession())

  componentForRole: Em.computed('session.currentRole', ->
    "stream-session-#{@get('session.currentRole')}"
  )

  hasSessionAndRole: Em.computed('session.hasCurrentRole', 'session.hasCurrentSession', ->
    @get('session.hasCurrentSession') && @get('session.hasCurrentRole')
  )

