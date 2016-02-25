require 'pry-byebug'

module ReginaEx
  class Test
    attr_reader :text, :to_match

    def initialize(text, should_match)
      @text = text
      @should_match = should_match
    end

    def evaluate(regex)
      matchdata = regex.match(@text)

      if !!matchdata == @should_match
        Result::Success.new(@text, @should_match)
      else
        Result::Failure.new(@text, @should_match)
      end
    end

    module Result
      class Success
        def initialize(text, should_match)
          @text = text
          @should_match = should_match
        end

        def to_s
          if @should_match
            "Matched #{ @text }, as required."
          else
            "Did not match #{ @text }, as required."
          end
        end
      end

      class Failure
        def initialize(text, should_match)
          @text = text
          @should_match = should_match
        end

        def to_s
          if @should_match
            "Did not match #{ @text }, but were meant to."
          else
            "Matched #{ @text }, but were not meant to."
          end
        end
      end
    end
  end

  class Level
    attr_reader :introduction_text

    def initialize(introduction_text, tests)
      @introduction_text = introduction_text
      @tests = tests
    end

    def challenge_texts
      @tests.each.map(&:text)
    end

    def attempt(regex)
      LevelResult.new(@tests.map { |test| test.evaluate(regex) })
    end
  end

  class LevelResult
    def initialize(test_results)
      @test_results = test_results
    end

    def to_s
      @test_results.map(&:to_s).join("\n")
    end

    def successful?
      @test_results.all? { |test_result| test_result.instance_of?(Test::Result::Success) }
    end
  end

  class Game
    require 'readline'

    def self.start_main_game_loop(levels)
      level = levels.shift

      puts "\n"
      puts 'WELCOME TO REGINA-EX!'
      puts "THE ***CRAAZY*** STRING MATCHING GAME EVERYONE'S TALKING ABOUT!"
      puts "Let's get started with those crazy strings shall we?"
      puts "\n"

      loop do
        puts level.introduction_text
        puts '-' * level.introduction_text.length
        puts "\n"
        puts "Test strings:"
        puts "\n"

        level.challenge_texts.each { |challenge, i|
          challenge = /\A\s*\z/ =~ challenge ? "\"#{ challenge }\"" : challenge
          puts "*   #{ challenge }"
        }

        puts "\n"

        answer = Readline.readline('> ', true)

        if answer.downcase == 'exit' || answer.downcase == 'quit'
          puts 'Bye...  o/'
          break
        end

        begin
          answer_regexp = Regexp.new answer
        rescue RegexpError
          puts 'Please enter a valid regex'
          puts "\n"
          next
        end

        result = level.attempt(answer_regexp)

        puts "\n"
        puts result
        puts "\n"

        if result.successful?
          unless levels.empty?
            level = levels.shift
          else
            puts "You've completed all the challenges!"
            break
          end
        else
          puts "\n"
          puts 'Please try again'
          puts "\n"
        end
      end
    end
  end
end

levels = [
  ReginaEx::Level.new('Match any strings containing a single character.', [
    ReginaEx::Test.new('Embark!', true),
    ReginaEx::Test.new("Let's go!", true),
    ReginaEx::Test.new("Proceed!", true),
    ReginaEx::Test.new("!", true),
    ReginaEx::Test.new("", false),
  ]),
  ReginaEx::Level.new('Match words with 5 or more non-whitespace characters.', [
    ReginaEx::Test.new('london', true),
    ReginaEx::Test.new("cap", false),
    ReginaEx::Test.new("cedar", true),
    ReginaEx::Test.new("a b c", false),
    ReginaEx::Test.new("..........", true),
    ReginaEx::Test.new("", false),
  ]),
  ReginaEx::Level.new('Match strings containing any digits', [
    ReginaEx::Test.new('yo', false),
    ReginaEx::Test.new('Call 999', true),
    ReginaEx::Test.new('1 is my favourite number!', true),
    ReginaEx::Test.new('8-)', true),
    ReginaEx::Test.new('zzzzzzzzz', false),
  ]),
  ReginaEx::Level.new('Match words beginning with a capital letter. (\b anchors the pattern at a word boundary)', [
    ReginaEx::Test.new('One', true),
    ReginaEx::Test.new('oNe', false),
    ReginaEx::Test.new('twO', false),
    ReginaEx::Test.new('three', false),
    ReginaEx::Test.new('Three', true),
  ]),
  ReginaEx::Level.new('Match any strings containing two consecutive lower-case vowels.', [
    ReginaEx::Test.new('bear', true),
    ReginaEx::Test.new("ribena", false),
    ReginaEx::Test.new("cheese", true),
    ReginaEx::Test.new("bread", true),
    ReginaEx::Test.new("CHEESE", false),
  ]),
  ReginaEx::Level.new('Match any strings containing two of the SAME consecutive lower-case vowels.', [
    ReginaEx::Test.new('boot', true),
    ReginaEx::Test.new("ribena", false),
    ReginaEx::Test.new("cheese", true),
    ReginaEx::Test.new("bread", false),
    ReginaEx::Test.new("bear", false),
    ReginaEx::Test.new("CHEESE", false),
  ]),
  ReginaEx::Level.new("Match any strings that do NOT contain the letter 'y'", [
    ReginaEx::Test.new('yoghurt', false),
    ReginaEx::Test.new('yacht', false),
    ReginaEx::Test.new('company', false),
    ReginaEx::Test.new('hello', true),
    ReginaEx::Test.new('harhar', true),
  ]),
  ReginaEx::Level.new('Match strings ending in one or more digits.', [
    ReginaEx::Test.new('4aaaa', false),
    ReginaEx::Test.new('aaaa45', true),
    ReginaEx::Test.new('     ', false),
    ReginaEx::Test.new('234234', true),
    ReginaEx::Test.new('a', false),
  ]),
  ReginaEx::Level.new('Match strings ending in an exclamation mark or question mark.', [
    ReginaEx::Test.new('hello', false),
    ReginaEx::Test.new('hello!', true),
    ReginaEx::Test.new('hello?', true),
    ReginaEx::Test.new('one two three four five', false),
    ReginaEx::Test.new('!', true),
  ]),
  ReginaEx::Level.new('Match strings with non-whitespace characters wrapped in 3 asterisks (*).', [
    ReginaEx::Test.new('     ***aaaaa***', true),
    ReginaEx::Test.new('**ARGH**', false),
    ReginaEx::Test.new('     ', false),
    ReginaEx::Test.new('hello', false),
    ReginaEx::Test.new('***hello***', true),
    ReginaEx::Test.new('********', false),
  ]),
  ReginaEx::Level.new('Match strings ending in three or four question marks.', [
    ReginaEx::Test.new('say what???', true),
    ReginaEx::Test.new('cheese????????', false),
    ReginaEx::Test.new('hello?', false),
    ReginaEx::Test.new('question????', true),
    ReginaEx::Test.new('!', false),
  ]),
  ReginaEx::Level.new('Match strings containing exactly 5 capital B characters in any position.', [
    ReginaEx::Test.new('BBBBB', true),
    ReginaEx::Test.new('aaabbbBbbbbbB', false),
    ReginaEx::Test.new('BBhellohelloBBB', true),
    ReginaEx::Test.new('whatwhat', false),
    ReginaEx::Test.new('Bbbbbbb___AWEIOAERNVLANV', false),
    ReginaEx::Test.new('B', false),
  ]),
  ReginaEx::Level.new("Match words containing either one 'a' or one 'b'.", [
    ReginaEx::Test.new('ab', true),
    ReginaEx::Test.new('a', true),
    ReginaEx::Test.new('bbbbb', false),
    ReginaEx::Test.new('shrub', true),
    ReginaEx::Test.new('acorn', true),
    ReginaEx::Test.new('345', false),
  ]),
]

ReginaEx::Game.start_main_game_loop(levels)
