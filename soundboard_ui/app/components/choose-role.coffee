import Ember from 'ember'

export default Ember.Component.extend
  session: Em.inject.service()
  actions:
    chooseRole: (role) ->
      @chooseRole(role)

    clearRole: ->
      @clearRole()


