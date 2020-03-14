import Ember from 'ember'

export default Ember.Component.extend
  youtube: Em.inject.service()
  store: Em.inject.service()
  video: null
  classNames: ['videoPlayerComponent']

  newVideoId: -> "video_#{@get('utility').randNum(10)}"

  didReceiveAttrs: ->
    @set('videoId', @newVideoId())

  didInsertElement: ->
    videoElem = document.getElementById(@get('videoId'))

    Em.run.next =>
      @get('youtube').createVideo(videoElem, @get('videoUrl')).then((video)=>
        @set('video', video)
        video.on('didFinishPlayingVideo', =>
          @didFinishPlayingVideo(video.player.getVideoData().video_id)
        )
        console.log 'addedvideo', video
      )
