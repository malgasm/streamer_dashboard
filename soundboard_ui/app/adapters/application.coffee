import DS from 'ember-data'
import config from '../config/environment'

export default DS.RESTAdapter.extend
  namespace: 'api'
  host: 'http://10.0.0.45:4000'
