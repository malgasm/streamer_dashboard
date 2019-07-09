import Ember from 'ember'

export default Ember.Service.extend
  messageBus: Em.inject.service()
  SOUNDS:
    airhorn: 'effect/sairhorn.mp3'
    everyones_gay: 'clips/everyonesgay.mp3'

  SOUNDS_EVENTS_MAP:
    gay: 'everyones_gay'

  getSoundFilePath: (key) -> "/audio/#{@SOUNDS[key]}"

  getSoundFromWebsocketEvent: (event) -> @SOUNDS_EVENTS_MAP[event]

  playSound: (type, file) ->
    @get('messageBus').publish('play-sound', @getSoundFilePath(type, file))
    #todo: sound opts, e.g. volume
