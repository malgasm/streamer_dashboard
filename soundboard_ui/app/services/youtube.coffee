`import Ember from 'ember'`

YoutubeVideo = Em.Object.extend(Em.Evented)

YoutubeService = Ember.Service.extend
  messageBus: Em.inject.service()
  websocket: Em.inject.service()

  init: (args) ->
    @_super(args)
    @get('messageBus').subscribe('stream_action', @, @didReceiveStreamAction)

  didReceiveStreamAction: (payload) ->
    if payload.type && payload.type == 'pause-video'
      @pause()
    if payload.type && payload.type == 'resume-video'
      @play(false)
    else if payload.type && payload.type == 'play-video' && !@get('video.control')
      @play()
    else if payload.type && payload.type == 'video-loaded' && @get('video.control')
      @play()
    else if payload.type && payload.type == 'video-time-update' && !@get('video.control')
      console.log 'seeking to', payload.value
      @seekTo(payload.value)

  createVideo: (elem, videoUrl, control=false) ->
    new Em.RSVP.Promise (resolve, reject) =>
      @set 'video', YoutubeVideo.create
        player: new YT.Player elem,
          height: '390'
          width: '640'
          videoId: videoUrl,
          playerVars:
            rel: 0
            color: 'white'
            modestbranding: 1
            autohide: 1
          events:
            'onReady': @onPlayerReady.bind(@)
            'onStateChange': @onStateChange.bind(@)

      @get('video').on('close', @closeVideo.bind(@))
      @set('video.control', control)
      resolve(@get('video'))

  seekTo: (time) ->
    @get('video.player').seekTo(time)

  pause: ->
    @get('video.player').pauseVideo()

  play: (broadcast=true)->
    console.log 'playing video'
    @get('video.player').playVideo()

  broadcastCurrentTime: (delay=2.5)->
    console.log @get('video.control')
    @get('websocket').sendMessage('video-time-update', @get('video.player').getCurrentTime()+delay) #todo: perform this elsewhere

  onPlayerReady: (evt) ->
    console.log 'setting volume to 6'
    @get('video.player').setVolume(6)
    @play()
    # @get('video.player').setPlaybackQuality('hd1080')

  closeVideo: ->
    @get('video.player').destroy()

  onStateChange: (evt) ->
    if evt
      switch evt.data
        when 0 #ended
          console.log 'video finished'
          @get('video').trigger('didFinishPlayingVideo', @get('video').videoId)
        when 1 #playing
          console.log 'playing'
          if @get('video.control')
            @get('websocket').sendMessage('resume-video', '') #todo: perform this elsewhere
          else
            @get('websocket').sendMessage('video-loaded', '') #todo: perform this elsewhere
        when 2 #paused
          console.log 'paused'
          if @get('video.control')
            @get('websocket').sendMessage('pause-video', '') #todo: perform this elsewhere
            @broadcastCurrentTime(0)
        when 3 #buffering
          console.log 'buffering'
        when 5 #cued
          console.log 'cued'

`export default YoutubeService`
