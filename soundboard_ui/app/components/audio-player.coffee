import Ember from 'ember'

export default Ember.Component.extend
  sounds: Em.inject.service()
  websocket: Em.inject.service()

  currentAudios: []

  actions:
    audioDidFinish: (sound) ->
      @removeSound(sound)
      @get('websocket').sendMessage('sound-ended', sound.id)

  didInsertElement: ->
    #sounds from chat
    @get('messageBus').subscribe('stream_action', @, (payload) ->
      if payload && payload.type && payload.type == 'play-sound'
        @playSound(@get('sounds').getSoundFilePath(payload.value))
      else if payload && payload.type && payload.type == 'finish-sound'
        @get('currentAudios').removeObjects(
          @get('currentAudios').filter((sound) -> console.log(JSON.stringify(sound)); sound.get('path').indexOf('loop.') != -1 )
        )
      else if payload && payload.type && payload.type == 'clear-all-sounds'
        @set('currentAudios', [])
    )

    #internal sounds (for testing?)
    @get('messageBus').subscribe('play-sound', @, (payload) ->
      @playSound(payload)
    )

  removeSound: (sound) ->
    @get('currentAudios').forEach((currentSound) =>
      if currentSound.id == sound.id
        @get('currentAudios').removeObject(sound)
    )

  stopSounds: ->
    #clear sounds array
    #programmatically stop currently playing sounds through HTML5 audio api - is removing the elements enough?

  playSound: (sound) ->
    console.log 'playSound!', sound
    @get('currentAudios').addObject(Em.Object.create(id: @get('utility').randNum(), path: sound))
