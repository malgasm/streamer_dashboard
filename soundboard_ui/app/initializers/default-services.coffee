# Takes two parameters: container and application
export initialize = (application) ->
  application.inject('component', 'utility', 'service:utility')
  application.inject('component', 'messageBus', 'service:messageBus')
  application.inject('component', 'store', 'service:store')

export default {
  name: 'default-services'
  initialize: initialize
}
