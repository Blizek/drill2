var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('DrillApp').service('Question', function(Answer) {
  var Question;
  return Question = (function() {
    function Question(body1, id1) {
      this.body = body1 != null ? body1 : '';
      this.id = id1;
      this.grade = bind(this.grade, this);
      this.explanation = false;
      this.relatedLinks = [];
      this.answers = [];
      this.matches = [];
      this.type = 'choice';
      this.scoreLog = [];
    }

    Question.prototype.addAnswer = function(body, correct, id) {
      var answer;
      answer = new Answer(body, correct, id);
      return this.answers.push(answer);
    };

    Question.prototype.addMatch = function(prompt, correct) {
      this.type = 'matching';
      return this.matches.push({
        id: this.matches.length,
        prompt: prompt.trim(),
        correct: correct.trim(),
        selected: ''
      });
    };

    Question.prototype.initializeMatching = function(shuffle) {
      var i, len, m, ref, ref1, s, shuffled, uniqueChoices;
      if (this.type !== 'matching') {
        return;
      }
      uniqueChoices = [];
      ref = this.matches;
      for (i = 0, len = ref.length; i < len; i++) {
        m = ref[i];
        if (ref1 = m.correct, indexOf.call(uniqueChoices, ref1) < 0) {
          uniqueChoices.push(m.correct);
        }
      }
      if (shuffle) {
        shuffled = uniqueChoices.map(function(choice) {
          return {
            choice: choice,
            key: Math.random()
          };
        });
        shuffled.sort(function(a, b) {
          return a.key - b.key;
        });
        return this.shuffledChoices = (function() {
          var j, len1, results;
          results = [];
          for (j = 0, len1 = shuffled.length; j < len1; j++) {
            s = shuffled[j];
            results.push(s.choice);
          }
          return results;
        })();
      } else {
        return this.shuffledChoices = uniqueChoices;
      }
    };

    Question.prototype.correctMatchesCount = function() {
      var count, i, len, match, ref;
      count = 0;
      ref = this.matches;
      for (i = 0, len = ref.length; i < len; i++) {
        match = ref[i];
        if ((match.selected != null) && match.selected !== '' && match.selected === match.correct) {
          count++;
        }
      }
      return count;
    };

    Question.prototype.incorrectMatchesCount = function() {
      var count, i, len, match, ref;
      count = 0;
      ref = this.matches;
      for (i = 0, len = ref.length; i < len; i++) {
        match = ref[i];
        if ((match.selected != null) && match.selected !== '' && match.selected !== match.correct) {
          count++;
        }
      }
      return count;
    };

    Question.prototype.missedMatchesCount = function() {
      var count, i, len, match, ref;
      count = 0;
      ref = this.matches;
      for (i = 0, len = ref.length; i < len; i++) {
        match = ref[i];
        if ((match.selected == null) || match.selected === '') {
          count++;
        }
      }
      return count;
    };

    Question.prototype.appendToLastAnswer = function(line) {
      return this.answers[this.answers.length - 1].append(line);
    };

    Question.prototype.countAnswers = function(filter) {
      var answer, count, i, len, ref;
      count = 0;
      ref = this.answers;
      for (i = 0, len = ref.length; i < len; i++) {
        answer = ref[i];
        if (filter(answer)) {
          count++;
        }
      }
      return count;
    };

    Question.prototype.totalCorrect = function() {
      if (this.type === 'matching') {
        return this.matches.length;
      } else {
        return this.countAnswers(function(answer) {
          return answer.correct;
        });
      }
    };

    Question.prototype.correct = function() {
      if (this.type === 'matching') {
        return this.correctMatchesCount();
      } else {
        return this.countAnswers(function(answer) {
          return answer.checked && answer.correct;
        });
      }
    };

    Question.prototype.incorrect = function() {
      if (this.type === 'matching') {
        return this.incorrectMatchesCount();
      } else {
        return this.countAnswers(function(answer) {
          return answer.checked && !answer.correct;
        });
      }
    };

    Question.prototype.missed = function() {
      if (this.type === 'matching') {
        return this.missedMatchesCount();
      } else {
        return this.countAnswers(function(answer) {
          return !answer.checked && answer.correct;
        });
      }
    };

    Question.prototype.grade = function(graderFunction) {
      var grade, time;
      grade = graderFunction(this);
      time = this.timeLeft != null ? this.timeLeft : 0;
      this.scoreLog.push({
        score: grade.score,
        total: grade.total,
        timeLeft: time
      });
      return grade;
    };

    Question.prototype.setExplanation = function(explanation) {
      this.explanation = explanation;
      return this.hasExplanations = true;
    };

    Question.prototype.setRelatedLinks = function(links) {
      return this.relatedLinks = links;
    };

    Question.prototype.toString = function(includeAnswers) {
      var answer, body, i, j, len, len1, match, ref, ref1;
      if (includeAnswers == null) {
        includeAnswers = true;
      }
      body = this.id != null ? "[#" + this.id + "] " + this.body : this.body;
      body = body.replace(/\n\n/g, '\n') + '\n';
      if (includeAnswers) {
        if (this.type === 'matching') {
          ref = this.matches;
          for (i = 0, len = ref.length; i < len; i++) {
            match = ref[i];
            body += "[match] " + match.prompt + " = " + match.correct + "\n";
          }
        } else {
          ref1 = this.answers;
          for (j = 0, len1 = ref1.length; j < len1; j++) {
            answer = ref1[j];
            body += answer.toString();
          }
        }
      }
      return body;
    };

    return Question;

  })();
});
