import Ember from 'ember'

export default Ember.Component.extend
  streamSession: Em.inject.service('stream-session-websocket')
  youtube: Em.inject.service()
  utility: Em.inject.service()
  messageBus: Em.inject.service()
  classNames: ['overlayContainer']
  elementId: 'overlayContainer'
  currentVideo: null
  animation: null
  brbImage: null
  videos: []

  actions:
    animationDidFinish: ->
      console.log 'animation complete.'

    didFinishPlayingVideo: (video) ->
      @removeVideo()
      Em.run.next => @playNextVideo()

  didInsertElement: ->
    @get('streamSession').listenForStreamSessionEvents(@didReceiveStreamAction.bind(@))
    @set('particleAnimation', new ParticleAnimation(document.getElementById('overlayContainer')))

  didReceiveStreamAction: (payload) ->
    console.log 'didReceiveStreamAction overlay', payload
    if payload.type && payload.type == 'brb-toggle'
      @toggleBrb(payload.value)
    else if payload.type && payload.type == 'set-brb-image'
      @setBrbImage(payload.value)
    else if payload.type && payload.type == 'animate-overlay'
      @animateOverlay(payload.value)
    else if payload.type && payload.type == 'skip-video'
      @removeVideo()
      Em.run.next => @playNextVideo()
    else if payload.type && payload.type == 'play-video'
      console.log 'play-video', payload
      @addVideoToQueue(payload.value)

  removeVideo: -> @set('currentVideo', null)

  addVideoToQueue: (video) ->
    console.log 'adding', video, 'to queue'
    newVideo = Em.Object.extend(Ember.Evented).create(
      url: @get('utility').extractYoutubeId(video.video)
    )
    @get('store').query('youtubeVideo', video_id: video.video).then((videos)=>
      newVideo.set('title', videos.get('firstObject.title'))
    )
    @get('videos').addObject(newVideo)
    @playNextVideo()

  playNextVideo: ->
    return if Em.isPresent(@get('currentVideo'))

    nextVideo = @get('videos').popObject()
    if nextVideo
      console.log 'playing video', nextVideo.video
      @set('currentVideo', nextVideo)

  animateOverlay: (params) ->
    console.log 'emote params', params
    emote = if params.emote.indexOf('http') != -1
      params.emote
    else
      new Emote()[params.emote]

    console.log 'emote', emote
    console.log 'count', params.count

    #todo: split simple count-based animations
    #and the buildup animation. this will allow
    #for more animation types to be specified.
    #
    @get('messageBus').publish('emote-animation', params.emote)
    if params.count < 30
      @get('particleAnimation').animateCount(emote, params.count)
    else
      @get('particleAnimation').buildupAnimation([emote], params.count)

  toggleBrb: (brb) -> @set('brb', brb)

  setBrbImage: (image) ->
    @set('brbImage', image)
    console.log 'successfully set brb image to ', @get('brbImage')

  nextVideo: Em.computed('videos.length', -> @get('videos').objectAt(0) )
