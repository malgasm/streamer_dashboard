import Ember from 'ember'

export default Ember.Component.extend
  tagName: 'li'
  classNames: ['groupedMessageTextContainer']

  messageText: Em.computed('message.text', 'message.emotes', ->
    if @get('message.emotes')
      @applyEmotes(@get('message.text'), @get('message.emotes'))
    else
      @get('message.text')
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
      text = @get('utility').escapeForRegex(emote.text)
      message = message.replace(new RegExp(text, 'ig'), @emoteImageTag(emote.id))

    message

  emoteImageTag: (id) -> "<img src=\"https://static-cdn.jtvnw.net/emoticons/v1/#{id}/1.0\" />"

