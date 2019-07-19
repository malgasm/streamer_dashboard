import Ember from 'ember'

export default Ember.Component.extend
  sounds: Em.inject.service()
  utility: Em.inject.service()
  messageBus: Em.inject.service()
  allSounds: []
  groupedSounds: {}
  classNames: ['audioControllerComponent']

  didInsertElement: ->
    @get('sounds').getSounds().then((sounds) =>@loadSounds(sounds))

  actions:
    clearAllSounds: ->
      @get('sounds').triggerClearSounds()

    playSound: (sound) ->
      console.log 'playing sound', sound
      @get('sounds').triggerSound(sound.path)

    playGroupedSound: (sound) ->
      @get('sounds').triggerSound(
        @get('utility').randomItem(@get('groupedSounds')[sound])
      )

  loadSounds: (sounds) ->
    groupedSounds = {}
    sounds.forEach (sound) =>
      if sound.get('isGroup')
        if Em.isEmpty(groupedSounds[@keyForGroupedSound(sound.key)])
          groupedSounds[@keyForGroupedSound(sound.key)] = [sound.path]
        else
          groupedSounds[@keyForGroupedSound(sound.key)].push(sound.path)
      else
        @get('allSounds').addObject(sound)
    @set('groupedSounds', groupedSounds)

  keyForGroupedSound: (key) -> key.replace(/\d+/ig, '')

  groupedSoundsForDisplay: Em.computed('groupedSounds.@each', ->
    Object.keys(@get('groupedSounds'))
  )
