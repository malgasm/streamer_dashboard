import Ember from 'ember'

export default Ember.Component.extend
  brb: false

  brbImageOptions: [
    {label: 'grin', value: 'https://static-cdn.jtvnw.net/emoticons/v1/300624501/3.0'},
    {label: 'love', value: 'https://static-cdn.jtvnw.net/emoticons/v1/300205588/3.0'},
    {label: 'kekw', value: 'https://cdn.frankerfacez.com/emoticon/381875/4'},
    {label: 'pepejammy', value: 'https://cdn.betterttv.net/emote/5bf621d00377f4124f663158/3x'},
    {label: 'widepeeposad', value: 'https://cdn.frankerfacez.com/emoticon/270930/4'}
    {label: 'gachibass', value: 'https://cdn.betterttv.net/emote/57719a9a6bdecd592c3ad59b/3x'}
    {label: 'widepeepohappy', value: 'https://cdn.frankerfacez.com/emoticon/270930/4'}
    {label: 'ppJedi', value: 'https://cdn.betterttv.net/emote/5b52e96eb4276d0be256f809/3x'}
  ]

  actions:
    didToggleBrb: ->
      @toggleProperty('brb')
      @didToggleBrb(@get('brb'))

    updateBrbEmote: (newImage) ->
      console.log 'changing brb emote to ', newImage
      @didChangeBrbEmote(newImage)

  didReceiveAttrs: ->
    @set('brbImage', @get('brbImageOptions.firstObject'))
