import Ember from 'ember'

export default Ember.Service.extend
  websocket: Em.inject.service()
  messageBus: Em.inject.service()
  store: Em.inject.service()

  getSounds: ->
    new Em.RSVP.Promise (resolve, reject) =>
      @get('store').findAll('sound').then (sounds) =>
        resolve(sounds)

  getSoundFilePath: (path) -> "http://peanut:4000/#{path}"

  allSounds: -> @get('store').peekAll('sound')

  triggerSound: (key, volume) -> @get('websocket').sendMessage('play-sound', {sound: key, volume: volume})

  triggerSoundFinish: (key) -> @get('websocket').sendMessage('finish-sound', key)

  triggerClearSounds: -> @get('websocket').sendMessage('clear-all-sounds', (new Date).toLocaleString())

  playSound: (file) ->
    @get('messageBus').publish('play-sound', @getSoundFilePath(file))
    #todo: sound opts, e.g. volume
