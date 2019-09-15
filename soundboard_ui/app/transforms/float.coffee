import DS from 'ember-data'

export default DS.Transform.extend
  deserialize: (serialized) ->
    parseFloat(serialized)

  serialize: (deserialized) ->
    parseFloat(deserialized)
