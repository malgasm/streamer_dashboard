import Ember from 'ember'

export default Ember.Service.extend
  randNum: (num = 10) -> parseInt(Math.random() * Math.pow(10, num))
  randomItem: (array) -> array[Math.floor(Math.random()*array.length)]

  isAnInt: (input) -> parseInt(input) != NaN

  extractYoutubeId: (videoUrl) ->
    urlObject = @getURLObject(videoUrl)

    if urlObject
      if urlObject.searchParams.get('v')
        urlObject.searchParams.get('v')
      else
        urlObject.pathname.slice(1, urlObject.pathname.length)
    else
      videoUrl

  getURLObject: (url) ->
    try
      new URL(url)
    catch e
      null
