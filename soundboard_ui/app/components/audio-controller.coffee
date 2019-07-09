import Ember from 'ember'

export default Ember.Component.extend
  sounds: Em.inject.service()
  messageBus: Em.inject.service()
  allSounds: []
  classNames: ['audioController']

  didInsertElement: ->
    allSounds = @get('sounds').allSounds()
    Object.keys(allSounds).forEach (key) =>
      console.log 'key', key
      @get('allSounds').addObject(
        Em.Object.create(title: key, id: allSounds[key])
      )
    console.log @get('allSounds')

  actions:
    playSound: (sound) ->
      console.log 'playing sound', sound
      @get('sounds').triggerSound(sound)

