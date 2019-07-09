import Ember from 'ember'

export default Ember.Component.extend
  messageBus: Em.inject.service()
  sounds: Em.inject.service()

  currentAudios: []
  didInsertElement: ->
    #sounds from chat
    @get('messageBus').subscribe('stream_action', @, (payload) ->
      if payload && payload.type && payload.type == 'play_sound'
        @playSound(@get('sounds').getSoundFilePath(@get('sounds').getSoundFromWebsocketEvent(payload.value)))
    )

    #internal sounds (for testing?)
    @get('messageBus').subscribe('play-sound', @, (payload) ->
      @playSound(@get('sounds').getSoundFilePath(payload))
    )

  stopSounds: ->
    #clear sounds array
    #programmatically stop currently playing sounds through HTML5 audio api - is removing the elements enough?

  playSound: (sound) ->
    console.log 'playSound!', sound
    @get('currentAudios').addObject(Em.Object.create(path: sound))

