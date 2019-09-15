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
        console.log 'playing sound from payload', payload
        @playSound(@get('sounds').getSoundFilePath(payload.value.sound), payload.value.volume)
      else if payload && payload.type && payload.type == 'finish-sound'
        @get('currentAudios').removeObjects(
          @get('currentAudios').filter((sound) -> console.log(JSON.stringify(sound)); sound.get('path').indexOf('loop.') != -1 )
        )
      else if payload && payload.type && payload.type == 'clear-all-sounds'
        @set('currentAudios', [])
    )

    #internal sounds (for testing?)
    @get('messageBus').subscribe('play-sound', @, (path, volume) ->
      @playSound(path, volume)
    )

  removeSound: (sound) ->
    @get('currentAudios').forEach((currentSound) =>
      if currentSound.id == sound.id
        @get('currentAudios').removeObject(sound)
    )

  stopSounds: ->
    #clear sounds array
    #programmatically stop currently playing sounds through HTML5 audio api - is removing the elements enough?

  playSound: (sound, volume = 1) ->
    console.log 'playSound!', sound, volume
    id = @get('utility').randNum()
    volume = parseFloat(volume)
    @get('currentAudios').addObject(Em.Object.create(id: id, path: sound, volume: volume))

    Em.run.next =>
      audioElement = document.getElementById(id)

      context = new (window.AudioContext || window.webkitAudioContext)
      result = {
        context: context,
        source: context.createMediaElementSource(audioElement),
        gain: context.createGain(),
        media: audioElement,
        amplify: (=> result.gain.gain.value = volume ),
        getAmpLevel: (=> result.gain.gain.value )
      }

      result.source.connect(result.gain)
      result.gain.connect(context.destination)
      result.amplify(volume)
      result
