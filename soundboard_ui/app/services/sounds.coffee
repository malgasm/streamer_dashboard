import Ember from 'ember'

export default Ember.Service.extend
  messageBus: Em.inject.service()
  websocket: Em.inject.service()
  store: Em.inject.service()

  getSounds: ->
    new Em.RSVP.Promise (resolve, reject) =>
      @get('store').findAll('sound').then (sounds) =>
        resolve(sounds)

  getSoundFilePath: (path) -> "http://10.0.0.45:4000/#{path}"

  allSounds: -> @get('store').peekAll('sound')

  triggerSound: (key) -> @get('websocket').sendMessage('play-sound', key)

  triggerClearSounds: -> @get('websocket').sendMessage('clear-all-sounds', (new Date).toLocaleString())

  playSound: (file) ->
    @get('messageBus').publish('play-sound', @getSoundFilePath(file))
    #todo: sound opts, e.g. volume
