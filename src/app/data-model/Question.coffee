angular.module('DrillApp').service 'Question', (Answer) ->
  class Question
    constructor: (@body = '', @id) ->
      @explanation = no
      @relatedLinks = []
      @answers = []
      @matches = []
      @type = 'choice'
      @scoreLog = []

    addAnswer: (body, correct, id) ->
      answer = new Answer(body, correct, id)
      @answers.push(answer)

    addMatch: (prompt, correct) ->
      @type = 'matching'
      @matches.push
        id: @matches.length
        prompt: prompt.trim()
        correct: correct.trim()
        selected: ''

    initializeMatching: (shuffle) ->
      if @type isnt 'matching'
        return
      uniqueChoices = []
      for m in @matches
        if m.correct not in uniqueChoices
          uniqueChoices.push(m.correct)
      if shuffle
        shuffled = uniqueChoices.map (choice) ->
          choice: choice
          key: Math.random()
        shuffled.sort (a, b) -> a.key - b.key
        @shuffledChoices = (s.choice for s in shuffled)
      else
        @shuffledChoices = uniqueChoices

    correctMatchesCount: ->
      count = 0
      for match in @matches
        if match.selected? and match.selected isnt '' and match.selected is match.correct
          count++
      count

    incorrectMatchesCount: ->
      count = 0
      for match in @matches
        if match.selected? and match.selected isnt '' and match.selected isnt match.correct
          count++
      count

    missedMatchesCount: ->
      count = 0
      for match in @matches
        if not match.selected? or match.selected is ''
          count++
      count

    # TODO remove this in favor of QuestionBuilder
    appendToLastAnswer: (line) ->
      @answers[@answers.length - 1].append(line)

    countAnswers: (filter) ->
      count = 0
      for answer in @answers
        count++ if filter(answer)
      count

    totalCorrect: ->
      if @type is 'matching'
        @matches.length
      else
        @countAnswers (answer) -> answer.correct

    correct: ->
      if @type is 'matching'
        @correctMatchesCount()
      else
        @countAnswers (answer) -> answer.checked and answer.correct

    incorrect: ->
      if @type is 'matching'
        @incorrectMatchesCount()
      else
        @countAnswers (answer) -> answer.checked and not answer.correct

    missed: ->
      if @type is 'matching'
        @missedMatchesCount()
      else
        @countAnswers (answer) -> not answer.checked and answer.correct

    grade: (graderFunction) =>
      grade = graderFunction(@)
      time = if @.timeLeft? then @timeLeft else 0

      @scoreLog.push
        score: grade.score
        total: grade.total
        timeLeft: time

      grade

    setExplanation: (explanation) ->
      @explanation = explanation
      @hasExplanations = yes

    setRelatedLinks: (links) ->
      @relatedLinks = links

    toString: (includeAnswers = yes) ->
      body = if @id? then "[##{@id}] #{@body}" else @body
      body = body.replace(/\n\n/g, '\n') + '\n'
      if includeAnswers
        if @type is 'matching'
          for match in @matches
            body += "[match] #{match.prompt} = #{match.correct}\n"
        else
          for answer in @answers
            body += answer.toString()
      body
