angular.module('DrillApp').service 'ParsingUtils', ->
  new class
    splitWithNewlines: (input) ->
      input.split(/(?:\r?\n)/)

    splitWithDoubleLines: (input) ->
      input.split(/(?:\r?\n){2,}/)

    matchAnswer: (str) ->
      # dot doesn't match newlines, [\s\S] matches everything (\S === [^\s])
      match = /^\s*(>+)?\s*([A-Z])\)\s*([\s\S]+)$/i.exec(str)
      if match
        correct: match[1]
        letter: match[2]
        content: match[3]
      else
        false

    matchMatch: (str) ->
      match = /^\s*\[match\]\s*([\s\S]+?)\s*(?:=|\||->)\s*([\s\S]+)$/i.exec(str)
      if match
        prompt: match[1].trim()
        correct: match[2].trim()
      else
        false

    matchIdentifier: (str) ->
      match = /^\[#([A-Z\d\-+_]+)]\s*([\s\S]*)$/i.exec(str)
      if match
        identifier: match[1]
        content: match[2]
      else
        false
