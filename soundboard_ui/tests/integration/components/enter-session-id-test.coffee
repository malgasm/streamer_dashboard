import { test, moduleForComponent } from 'ember-qunit'
import hbs from 'htmlbars-inline-precompile'

moduleForComponent 'enter-session-id', 'Integration | Component | enter-session-id', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{enter-session-id}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#enter-session-id}}
      template block text
    {{/enter-session-id}}
  """

  assert.equal @$().text().trim(), 'template block text'
