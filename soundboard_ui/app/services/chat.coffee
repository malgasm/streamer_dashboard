import Ember from 'ember'
import config from '../config/environment'

export default Ember.Service.extend
  websocket: Em.inject.service()
  messageBus: Em.inject.service()
  store: Em.inject.service()

  getLatestChat: ->
    new Em.RSVP.Promise (resolve, reject) =>
      @get('store').query('stream-message', latest: true).then (messages) =>
        resolve(messages)
