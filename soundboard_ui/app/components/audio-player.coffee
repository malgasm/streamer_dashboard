import Ember from 'ember'

export default Ember.Component.extend
  messageBus: Em.inject.service()
  currentAudios: []
  didInsertElement: ->
    @get('messageBus').subscribe('play-sound', @, (payload) ->
      @playSound(payload)
    )

  stopSounds: ->
    #clear sounds array
    #programmatically stop currently playing sounds through HTML5 audio api - is removing the elements enough?

  playSound: (sound) ->
    @get('currentAudios').addObject(Em.Object.create(path: sound))

