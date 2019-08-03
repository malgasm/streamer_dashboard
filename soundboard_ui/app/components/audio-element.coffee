import Ember from 'ember'

export default Ember.Component.extend
  didInsertElement: ->
    # @$('audio').get().onloadstart = ->
    #   console.log 'onloadstart'
    #   @volume = 1

    @$('audio').on('ended', =>
      @ended(@get('sound.id'))
    )

    if @get('sound.path').indexOf('.loop') != -1
      @$('audio').on('ended', ->
        @currentTime=0
        @play()
      )
