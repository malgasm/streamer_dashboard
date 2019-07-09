import Ember from 'ember'

export default Ember.Service.extend
  messageBus: Em.inject.service()
  websocket: Em.inject.service()

  SOUNDS:
    airhorn: 'effects/airhorn.mp3'
    awaken: 'songs/awaken.mp3'
    everyones_gay: 'clips/everyonesgay.mp3'

  SOUNDS_EVENTS_MAP:
    gay: 'everyones_gay'
    airhorn: 'airhorn'
    awaken: 'awaken'

  getSoundFilePath: (key) -> "/audio/#{@SOUNDS[key]}"

  getSoundFromWebsocketEvent: (event) -> @SOUNDS_EVENTS_MAP[event]

  allSounds: -> @SOUNDS_EVENTS_MAP

  triggerSound: (key) -> @get('websocket').sendMessage('play-sound', key)

  playSound: (file) ->
    @get('messageBus').publish('play-sound', @getSoundFilePath(file))
    #todo: sound opts, e.g. volume
