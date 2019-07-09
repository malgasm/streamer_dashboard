import Ember from 'ember'

export default Ember.Component.extend
  didInsertElement: ->
    # @$('audio').get().onloadstart = ->
    #   console.log 'onloadstart'
    #   @volume = 1

    @$('audio').on('ended', =>
      @ended(@get('sound.id'))
    )
