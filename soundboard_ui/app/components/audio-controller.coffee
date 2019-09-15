import Ember from 'ember'
import { debounce } from '@ember/runloop'

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

    didUpdateVolume: (sound) ->
      volume = @$(".#{sound.get('keyForCss')} .form-control-range").val()
      console.log "setting volume for #{sound.get('key')} to #{volume}"
      sound.set('volume', volume)

      Em.run.debounce sound, @saveVolume, 600

    playSoundAction: (sound) ->
      console.log 'playing sound', sound
      @get('sounds').triggerSound(sound.path, sound.volume)
      @incrementNumSounds()

    playGroupedSoundAction: (sound) ->
      @get('sounds').triggerSound(
        @get('utility').randomItem(@get('groupedSounds')[sound]),
        2
      )
      @incrementNumSounds()

  saveVolume: (sound) ->
    console.log "saving volume for #{@get('key')} to #{@get('volume')}"
    window.localStorage.setItem("#{@get('key')}.volume", @get('volume'))

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
