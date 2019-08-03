import Ember from 'ember'
import {Socket} from "phoenix"
import ENV from "soundboard-ui/config/environment"

export default Ember.Service.extend
  messageBus: Em.inject.service()

  channel: null
  joined_channel: null
  connect: (key) ->
    socket = new Socket(ENV.websocketURL)

    socket.connect()

    chan = socket.chan("stream_session:lobby", {seession_id: key})

    chan.on('stream_action', (payload) =>
      console.log 'stream_action occurred', payload
      @get('messageBus').publish('stream_action', payload)
    )

    chan.join()
      .receive('ok', ->
        console.log("successfully connected to websocket stream session", key)
      )

    @set('channel', chan)

  sendMessage: (type, value) ->
    console.log 'sendMessage', type, value
    @get('channel').push('stream_action', {type: type, value: value})
