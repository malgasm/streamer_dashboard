import Ember from 'ember'

export default Ember.Component.extend
  messageBus: Em.inject.service()
  sounds: Em.inject.service()
  utility: Em.inject.service()
  websocket: Em.inject.service()

  currentAudios: []

  actions:
    audioDidFinish: (soundId) ->
      @removeSound(soundId)
      @get('websocket').sendMessage('sound-ended', soundId)

  didInsertElement: ->
    #sounds from chat
    @get('messageBus').subscribe('stream_action', @, (payload) ->
      if payload && payload.type && payload.type == 'play-sound'
        @playSound(@get('sounds').getSoundFilePath(payload.value))
      else if payload && payload.type && payload.type == 'clear-all-sounds'
        @set('currentAudios', [])
    )

    #internal sounds (for testing?)
    @get('messageBus').subscribe('play-sound', @, (payload) ->
      @playSound(payload)
    )

  removeSound: (soundId) ->
    @get('currentAudios').forEach((sound) =>
      if sound.id == soundId
        @get('currentAudios').removeObject(sound)
    )

  stopSounds: ->
    #clear sounds array
    #programmatically stop currently playing sounds through HTML5 audio api - is removing the elements enough?

  playSound: (sound) ->
    console.log 'playSound!', sound
    @get('currentAudios').addObject(Em.Object.create(id: @get('utility').randNum(), path: sound))
