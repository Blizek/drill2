# coffeelint: disable=no_unnecessary_double_quotes
# because it doesn't work properly with block strings

describe 'Question', ->
  beforeEach ->
    module('DrillApp')
    jasmine.addMatchers(customMatchers)
    inject (@Question) ->

  it 'should stringify into question without ID', ->
    question = new @Question('body')
    question.addAnswer('incorrect', no, 'i')
    question.addAnswer('correct', yes, 'C')
    expect(question.toString()).toEqual """
                                        body
                                          i) incorrect
                                        > C) correct

                                        """

  it 'should stringify into question with ID', ->
    question = new @Question('body', 'id')
    question.addAnswer('correct', yes, 'C')
    question.addAnswer('incorrect', no, 'i')
    expect(question.toString()).toEqual """
                                        [#id] body
                                        > C) correct
                                          i) incorrect

                                        """

  it 'should stringify into question with multi-line body', ->
    question = new @Question('body\nmore body\neven more body')
    question.addAnswer('incorrect', no, 'i')
    question.addAnswer('correct', yes, 'C')
    expect(question.toString()).toEqual """
                                        body
                                        more body
                                        even more body
                                          i) incorrect
                                        > C) correct

                                        """

  it 'should stringify into question without answers', ->
    question = new @Question('body')
    question.addAnswer('incorrect', no, 'i')
    question.addAnswer('correct', yes, 'C')
    expect(question.toString(no)).toEqual """
                                        body

                                        """

  it 'should stringify into matching question', ->
    question = new @Question('body', 'id')
    question.addMatch('Poland', 'Warsaw')
    question.addMatch('Germany', 'Berlin')
    expect(question.toString()).toEqual """
                                        [#id] body
                                        [match] Poland = Warsaw
                                        [match] Germany = Berlin

                                        """

  it 'should initialize and shuffle matching choices', ->
    question = new @Question('body')
    question.addMatch('Poland', 'Warsaw')
    question.addMatch('Germany', 'Berlin')
    question.addMatch('France', 'Paris')
    question.initializeMatching(no)
    expect(question.shuffledChoices).toEqual(['Warsaw', 'Berlin', 'Paris'])

    question.initializeMatching(yes)
    expect(question.shuffledChoices.length).toBe(3)
    expect(question.shuffledChoices).toContain('Warsaw')
    expect(question.shuffledChoices).toContain('Berlin')
    expect(question.shuffledChoices).toContain('Paris')

  it 'should calculate correct, incorrect, and missed counts for matching', ->
    question = new @Question('body')
    question.addMatch('Poland', 'Warsaw')
    question.addMatch('Germany', 'Berlin')
    question.addMatch('France', 'Paris')

    # No answers selected yet
    expect(question.totalCorrect()).toBe(3)
    expect(question.correct()).toBe(0)
    expect(question.incorrect()).toBe(0)
    expect(question.missed()).toBe(3)

    # Some correct, some incorrect, some missed
    question.matches[0].selected = 'Warsaw'
    question.matches[1].selected = 'Paris' # Incorrect
    question.matches[2].selected = ''      # Missed

    expect(question.totalCorrect()).toBe(3)
    expect(question.correct()).toBe(1)
    expect(question.incorrect()).toBe(1)
    expect(question.missed()).toBe(1)
