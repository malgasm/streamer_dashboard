import Ember from 'ember'

export default Ember.Component.extend
  tagName: 'li'
  classNames: ['groupedMessageTextContainer']

  messageText: Em.computed('message.text', 'message.emotes', 'message.other_emotes', ->
    messageText = if @get('message.other_emotes')
      @applyOtherEmotes(@get('message.text'), @get('message.other_emotes'))
    else
      @get('message.text')

    if @get('message.emotes')
      @applyEmotes(messageText, @get('message.emotes'))
    else
      messageText
  )

  applyOtherEmotes: (message, emotesText) ->
    emotes = emotesText.split(';')
    newMessage = message
    emotes.map (emote) =>
      [url, locations] = emote.split('|')

      locations = locations.split(',')
      [start, end] = locations[0].split('-')

      emoteText = message.substring(parseInt(start), parseInt(end))

      text = @get('utility').escapeForRegex(emoteText)
      newMessage = newMessage.replace(new RegExp(text, 'ig'), @otherEmoteImageTag(url))

    newMessage

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
      message = message.replace(new RegExp(text, 'ig'), @twitchEmoteImageTag(emote.id))

    message

  twitchEmoteImageTag: (id) -> "<img src=\"https://static-cdn.jtvnw.net/emoticons/v1/#{id}/1.0\" />"
  otherEmoteImageTag: (url) -> "<img src=\"#{url}\" />"

