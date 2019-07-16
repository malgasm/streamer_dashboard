import Ember from 'ember'

export default Ember.Service.extend
  messageBus: Em.inject.service()
  websocket: Em.inject.service()

  SOUNDS:
    airhorn:                  'effects/airhorn.mp3'
    awaken:                   'songs/awaken.mp3'
    everyones_gay:            'clips/everyonesgay.mp3'
    ohshit:                   'clips/ohshit.mp3'
    itsinthewaythatyouuseit:  'songs/itsinthewaythatyouuseit.mp3'
    poop1:                    'effects/poop1.mp3'
    poop2:                    'effects/poop2.mp3'
    poop3:                    'effects/poop3.mp3'
    sooner:                    'clips/sooner.mp3'

  SOUNDS_EVENTS_MAP:
    gay: 'everyones_gay'
    airhorn: 'airhorn'
    awaken: 'awaken'
    sooner: 'sooner'
    poop1: 'poop1'
    poop2: 'poop2'
    poop3: 'poop3'
    useit: 'itsinthewaythatyouuseit'
    ohshit: 'ohshit'

  getSoundFilePath: (key) -> "/audio/#{@SOUNDS[key]}"

  getSoundFromWebsocketEvent: (event) -> @SOUNDS_EVENTS_MAP[event]

  allSounds: -> @SOUNDS_EVENTS_MAP

  triggerSound: (key) -> @get('websocket').sendMessage('play-sound', key)

  triggerClearSounds: -> @get('websocket').sendMessage('clear-all-sounds', {})

  playSound: (file) ->
    @get('messageBus').publish('play-sound', @getSoundFilePath(file))
    #todo: sound opts, e.g. volume
