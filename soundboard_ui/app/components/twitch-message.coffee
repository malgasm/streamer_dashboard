import Ember from 'ember'

export default Ember.Component.extend
  tagName: 'li'
  classNames: ['groupedMessageTextContainer']

  messageText: Em.computed('text', 'emotes', ->
    if @get('message.emotes')
      @applyEmotes(@get('message.text'), @get('message.emotes'))
    else
      @get('text')
  )

  applyEmotes: (message, emotesText) ->
    emotes = emotesText.split('/').map (emote) => {text: emote}
    replacements = []

    emotes.map (emote) =>
      [emote.id, emote.locations] = emote.text.split(':')
      emote.locations = emote.locations.split(',')
      [start, end] = emote.locations[0].split('-')
      emote.text = message.substring(start, end + 1).split(' ')[0]

    emotes.map (emote) =>
      message = message.replace(new RegExp(emote.text, 'ig'), @emoteImageTag(emote.id))

    message

  emoteImageTag: (id) -> "<img src=\"https://static-cdn.jtvnw.net/emoticons/v1/#{id}/1.0\" />"

