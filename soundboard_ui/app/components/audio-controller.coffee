import Ember from 'ember'

export default Ember.Component.extend
  sounds: Em.inject.service()
  messageBus: Em.inject.service()
  allSounds: []
  classNames: ['audioControllerComponent']

  didInsertElement: ->
    @get('sounds').getSounds().then (sounds) =>
      @set('allSounds', sounds)

  actions:
    clearAllSounds: ->
      @get('sounds').triggerClearSounds()

    playSound: (sound) ->
      console.log 'playing sound', sound
      @get('sounds').triggerSound(sound.path)
