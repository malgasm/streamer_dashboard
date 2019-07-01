import Ember from 'ember'
import {Socket} from "phoenix"

export default Ember.Service.extend
  connect: (key) ->
    socket = new Socket("ws://10.0.0.45:4000/socket/websocket") #todo: env

    socket.connect()

    chan = socket.chan("stream_session:lobby", {seession_id: key})
    chan.join().receive 'ok', ->
      console.log("successfully connected")
