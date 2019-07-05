import Ember from 'ember'
import {Socket} from "phoenix"

export default Ember.Service.extend
  messageBus: Em.inject.service()
  channel: null
  joined_channel: null
  connect: (key) ->
    socket = new Socket("ws://10.0.0.45:4000/socket/websocket") #todo: env

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

    Em.run.later @, ->
      chan.push('stream_action',
        {
          type: 'derp',
          value: 'herp'
        })
    , 200

    window.z = chan

  sendMessage: (type, value) ->
    @get('channel').push('stream_action', {type: type, value: value})
