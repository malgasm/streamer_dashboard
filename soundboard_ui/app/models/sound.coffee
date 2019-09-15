import DS from 'ember-data'

export default DS.Model.extend
  key:      DS.attr('string')
  path:     DS.attr('string')
  volume:   DS.attr('float')
  icon:     DS.attr('string')
  isGroup:  DS.attr('boolean')
  loops:    DS.attr('boolean')

  keyForCss: Em.computed('key', ->
    @get('key').replace('.', '_')
  )

  init: (args) ->
    @_super(args)
    if @get('key').search(/\d/ig) != -1
      @set('isGroup', true)
    if @get('key').indexOf('loop.') != -1
      @set('loops', true)
    @set('volume', window.localStorage.getItem("#{@get('key')}.volume") || 1)
