import Ember from 'ember'

export default Ember.Service.extend
  messageBus: Em.inject.service()
  SOUNDS:
    effects:
      airhorn: 'airhorn.mp3'

  getSoundFilePath: (type, file) -> "/audio/effects/#{@SOUNDS[type][file]}"

  playSound: (type, file) ->
    @get('messageBus').publish('play-sound', @getSoundFilePath(type, file))
    #todo: sound opts, e.g. volume
