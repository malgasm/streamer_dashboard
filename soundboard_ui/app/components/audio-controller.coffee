import Ember from 'ember'

export default Ember.Component.extend
  sounds: Em.inject.service()
  allSounds: []
  groupedSounds: {}
  classNames: ['audioControllerComponent']
  numPlayingSounds: 0

  actions:
    onContextMenuOpen: (evt) ->
      return unless evt
      evt.preventDefault()
      evt.stopPropagation()

    clearAllSounds: ->
      @get('sounds').triggerClearSounds()
      @set('numPlayingSounds', 0)

    finishPlayingSound: (sound) ->
      console.log 'fps', sound
      @get('sounds').triggerSoundFinish(sound)

    playSound: (sound) ->
      console.log 'playing sound', sound
      @get('sounds').triggerSound(sound.path)
      @incrementNumSounds()

    playGroupedSound: (sound) ->
      @get('sounds').triggerSound(
        @get('utility').randomItem(@get('groupedSounds')[sound])
      )
      @incrementNumSounds()

  didInsertElement: ->
    @get('sounds').getSounds().then((sounds) =>@loadSounds(sounds))

    @get('messageBus').subscribe('stream_action', @, (payload) =>
      if payload && payload.type && payload.type == 'sound-ended'
        @decrementNumSounds()
    )

  isPlayingSound: Em.computed('numPlayingSounds', -> @get('numPlayingSounds') > 0)
  incrementNumSounds: -> @set('numPlayingSounds', @get('numPlayingSounds') + 1)
  decrementNumSounds: -> @set('numPlayingSounds', @get('numPlayingSounds') - 1)

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
