import Ember from 'ember'
import { observer } from '@ember/object'

export default Ember.Component.extend
  bounce: null
  xDir: null
  yDir: null
  speed: 3
  maxSpeed: 5
  logoWidth: 250
  logoHeight: 250
  imageUrl: 'https://static-cdn.jtvnw.net/emoticons/v1/300624501/2.0'

  didInsertElement: -> @addBounce()

  addBounce: ->
    @set('bounce', new bounceEffect(
      speed: @get('speed')
      maxSpeed: @get('maxSpeed')
      logoWidth: @get('logoWidth')
      logoHeight: @get('logoHeight')
      imageUrl: @get('imageUrl')
    ))
    window.b = @get('bounce')

  willDestroyElement: -> @removeBounce()

  removeBounce: (bounce) -> @get('bounce').destroy()

  dirObserver: observer('xDir','yDir', ->
    console.log 'dirObserver', @get('xDir'), @get('yDir')
    @changeDirection(@get('xDir'), @get('yDir'))
    @setProperties
      xDir: null
      yDir: null
  )

  changeDirection: (xDir, yDir) ->
    @get('bounce').changeDirection(xDir, yDir)
