import Ember from 'ember'

export default Ember.Service.extend
  possibleHexValues: [0..9].concat(['A', 'B', 'C', 'D', 'E', 'F'])
  lettersInAlphabet: ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

  textToHex: (text, referenceText = null) ->
    return "ff0000" if Em.isEmpty(text)
    hash = 0
    text.split("").map (char) =>
      hash = char.charCodeAt(0) + ((hash << 5) - hash)

    hash = hash & 0x00FFFFFF

    if ((hash & 0xFF00000) < 0x00500000)
      hash = hash | 0x00500000

    if ((hash & 0x000FF00) < 0x00005000)
      hash = hash | 0x00005000

    if ((hash & 0x00000FF) < 0x00000050)
      hash = hash | 0x00000050

    hash.toString(16).toUpperCase()

  isUpperCase: (letter) -> letter.toUpperCase() == letter
  isLowerCase: (letter) -> !@isUpperCase(letter)

  hexIndexFromLetter: (letter, max) ->
    letterIndex = @lettersInAlphabet.indexOf(letter)
    return "0" if letterIndex == - 1
    if letterIndex < max
      return letterIndex
    else
      halfIndex = parseInt(letterIndex / 2)
      if halfIndex < max
        return halfIndex
      else
        return halfIndex - ((max - halfIndex) + 1)
