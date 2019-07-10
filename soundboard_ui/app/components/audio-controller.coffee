import Ember from 'ember'

export default Ember.Component.extend
  sounds: Em.inject.service()
  messageBus: Em.inject.service()
  allSounds: []
  classNames: ['audioControllerComponent']

  didInsertElement: ->
    allSounds = @get('sounds').allSounds()
    Object.keys(allSounds).forEach (key) =>
      @get('allSounds').addObject(
        Em.Object.create(title: key, id: allSounds[key])
      )

  actions:
    clearAllSounds: ->
      @get('sounds').triggerClearSounds()

    playSound: (sound) ->
      console.log 'playing sound', sound
      @get('sounds').triggerSound(sound)

