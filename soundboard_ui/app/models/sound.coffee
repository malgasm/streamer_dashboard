import DS from 'ember-data'

export default DS.Model.extend
  key: DS.attr('string')
  path: DS.attr('string')
  isGroup: DS.attr('boolean')

  init: (args) ->
    @_super(args)
    if @get('key').search(/\d/ig) != -1
      @set('isGroup', true)

