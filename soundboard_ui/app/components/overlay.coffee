import Ember from 'ember'

export default Ember.Component.extend
  streamSession: Em.inject.service('stream-session-websocket')
  classNames: ['overlayContainer']
  elementId: 'overlayContainer'
  animation: null
  brbImage: null
  videos: []

  actions:
    animationDidFinish: ->
      console.log 'animation complete.'

    didFinishPlayingVideo: (video) -> @removeVideo(video)

  didInsertElement: ->
    @get('streamSession').listenForStreamSessionEvents(@didReceiveStreamAction.bind(@))
    @set('particleAnimation', new ParticleAnimation(document.getElementById('overlayContainer')))
    window.b = @

  didReceiveStreamAction: (payload) ->
    console.log 'didReceiveStreamAction overlay', payload
    if payload.type && payload.type == 'brb-toggle'
      @toggleBrb(payload.value)
    else if payload.type && payload.type == 'set-brb-image'
      @setBrbImage(payload.value)
    else if payload.type && payload.type == 'animate-overlay'
      @animateOverlay(payload.value)
    else if payload.type && payload.type == 'play-video'
      console.log 'play-video', payload
      @playVideo(payload.value)

  removeVideo: (video) ->
    console.log 'remove video', video, @get('videos').mapBy('url')
    @get('videos').filterBy('url', video).map (video) =>
      console.log 'video', video
      @get('videos').removeObject(video)

  playVideo: (video) ->
    newVideo = Em.Object.extend(Ember.Evented).create(
      url: video.video
    )

    @get('videos').addObject(newVideo)
    console.log 'playing video', video.video

  animateOverlay: (params) ->
    emote = new Emote()[params.emote]
    console.log 'emote', emote
    console.log 'count', params.count

    #todo: split simple count-based animations
    #and the buildup animation. this will allow
    #for more animation types to be specified.
    if params.count < 30
      @get('particleAnimation').animateCount(emote, params.count)
    else
      @get('particleAnimation').buildupAnimation([emote], params.count)

  toggleBrb: (brb) -> @set('brb', brb)

  setBrbImage: (image) ->
    @set('brbImage', image)
    console.log 'successfully set brb image to ', @get('brbImage')
