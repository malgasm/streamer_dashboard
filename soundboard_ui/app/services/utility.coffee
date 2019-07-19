import Ember from 'ember'

export default Ember.Service.extend
  randNum: (num = 10) -> parseInt(Math.random() * Math.pow(10, num))
  randomItem: (array) -> array[Math.floor(Math.random()*array.length)]
