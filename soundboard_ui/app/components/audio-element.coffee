import Ember from 'ember'

export default Ember.Component.extend
  didInsertElement: ->
    @element.getElementsByTagName('audio')[0].addEventListener('ended', =>
      if @get('sound.path').indexOf('loop') != -1
        audioElem = @element.getElementsByTagName('audio')[0]
        audioElem.currentTime=0
        audioElem.play()
      else
        @ended(@get('sound.id'))
    )
