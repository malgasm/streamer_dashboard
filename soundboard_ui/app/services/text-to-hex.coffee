import Ember from 'ember'

export default Ember.Service.extend
  possibleHexValues: [0..9].concat(['A', 'B', 'C', 'D', 'E', 'F'])
  lettersInAlphabet: ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

  textToHex: (text, referenceText = null) ->
    referenceText = text if Em.isNone(referenceText)
    if Em.isEmpty(text) || text.length < 3
      return "#ffffff"
    return @textToHex(text + "x") if text.length < 4

    firstChar = text[0]
    lastChar = text[text.length - 1]
    thirdChar = text[1]
    fourthChar = text[text.length- 2]
    middleChar = text[parseInt(text.length / 2)]
    chosenChars = [middleChar, firstChar, thirdChar, fourthChar, lastChar, middleChar]
    console.log 'chosen characters', chosenChars.join('')

    "#" + chosenChars.map((char) =>
        @possibleHexValues[@hexIndexFromLetter(char, @possibleHexValues.length)]
    ).join('')

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
