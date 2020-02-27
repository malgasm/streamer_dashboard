`import Ember from 'ember'`

YoutubeVideo = Em.Object.extend(Em.Evented)

YoutubeService = Ember.Service.extend
  createVideo: (elem, videoUrl) ->
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
      resolve(@get('video'))

  pause: ->
    @get('video.player').pauseVideo()

  play: ->
    console.log 'starting autoplay'
    @get('video.player').playVideo()

  onPlayerReady: (evt) ->
    @play()
    console.log 'setting volume to 6'
    @get('video.player').setVolume(6)
    # @get('video.player').setPlaybackQuality('hd1080')

  closeVideo: ->
    @get('video.player').destroy()

  onStateChange: (evt) ->
    if evt
      switch evt.data
        when 0 #ended
          console.log 'video finished'
          @get('video').trigger('didFinishPlayingVideo', @get('video').videoId)
        # when 1 #playing
        # when 2 #paused
        # when 3 #buffering

`export default YoutubeService`
