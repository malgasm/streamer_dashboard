import Ember from 'ember'

export default Ember.Component.extend
  streamSession: Em.inject.service('stream-session-websocket')
  videos: []
  currentVideo: null

  actions:
    didFinishPlayingVideo: (video) ->
      @removeVideo()
      Em.run.next => @playNextVideo()

  didInsertElement: -> @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    console.log 'didReceiveStreamAction controller', payload
    if payload.type && payload.type == 'skip-video'
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
