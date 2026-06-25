angular.module('DrillApp').service 'QuestionBuilder', (Question) ->
  class QuestionBuilder
    identifier: null
    bodyLines: null
    question: null
    answer:
      lines: []
      correct: null
      identifier: null
    match:
      lines: []
      prompt: null

    constructor: ->
      @bodyLines = []
      @matches = []
      @match = {lines: []}

    setIdentifier: (identifier) ->
      if @identifier?
        throw new Error('Identifier already set')
      @identifier = identifier
      @

    appendToBody: (line) ->
      if @question?
        throw new Error('Answers already appended')
      @bodyLines.push(line)
      @

    _buildQuestion: ->
      @question = new Question(@bodyLines.join('\n\n'), @identifier)

    _pushAnswer: ->
      answerBody = @answer.lines.join('\n')
      @question.addAnswer(answerBody, @answer.correct, @answer.identifier)
      @answer.lines = []

    _pushMatch: ->
      matchCorrect = @match.lines.join('\n')
      @question.addMatch(@match.prompt, matchCorrect)
      @match.lines = []

    addAnswer: (line, correct, identifier) ->
      if not @question?
        @_buildQuestion()
      else if @answer.lines.length
        @_pushAnswer()
      else if @match.lines.length
        @_pushMatch()
      @answer.lines.push(line.trim())
      @answer.correct = correct
      @answer.identifier = identifier
      @

    addAnswers: (answers) ->
      if not @question?
        @_buildQuestion()
      else if @answer.lines.length
        @_pushAnswer()
      else if @match.lines.length
        @_pushMatch()
      for answer in answers
        @question.addAnswer(answer.body, answer.correct, answer.id)
      @

    appendAnswerLine: (line) ->
      if not @answer.lines.length
        throw new Error('Answer not created yet')
      @answer.lines.push(line.trim())
      @

    addMatch: (prompt, correct) ->
      if not @question?
        @_buildQuestion()
      else if @answer.lines.length
        @_pushAnswer()
      else if @match.lines.length
        @_pushMatch()
      @match.prompt = prompt
      @match.lines.push(correct)
      @

    appendMatchLine: (line) ->
      if not @match.lines.length
        throw new Error('Match not created yet')
      @match.lines.push(line.trim())
      @

    build: ->
      if not @question?
        @_buildQuestion()
      else if @answer.lines.length
        @_pushAnswer()
      else if @match.lines.length
        @_pushMatch()
      @question
