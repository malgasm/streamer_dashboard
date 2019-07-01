import Ember from 'ember'

export default Ember.Service.extend
  sessionId: null
  currentRole: null

  setCurrentSession: (streamSessionId) ->
    console.log 'saving session id', streamSessionId
    @set('sessionId', streamSessionId)
    window.localStorage.setItem('stream_session_id', streamSessionId)

  setCurrentRole: (role) ->
    console.log 'saving role', role
    @set('currentRole', role)
    window.localStorage.setItem('stream_session_role', role)

  getCurrentSession: ->
    sessionId = window.localStorage.getItem('stream_session_id')
    @set('sessionId', sessionId)

  getCurrentRole: ->
    currentRole = window.localStorage.getItem('stream_session_role')
    @set('currentRole', currentRole)

  hasCurrentSession: Em.computed('sessionId', ->
    currentSession = @getCurrentSession()
    console.log 'hcs currentSession', currentSession
    window.localStorage && !Em.isEmpty(currentSession) && currentSession != 'undefined'
  )

  hasCurrentRole: Em.computed('currentRole', ->
    currentRole = @getCurrentRole()
    console.log 'hcr currentRole', currentRole
    window.localStorage && !Em.isEmpty(currentRole) && currentRole != 'undefined'
  )

  clearCurrentSession: ->
    console.log 'clearing current session'
    @set('sessionId', null)
    window.localStorage.removeItem('stream_session_id')

  clearCurrentRole: ->
    console.log 'clearing current role'
    @set('currentRole', null)
    window.localStorage.removeItem('stream_session_role')
