import DS from 'ember-data'
import config from '../config/environment'
import ApplicationAdapter from './application'

export default ApplicationAdapter.extend
  pathForType: -> 'messages'
