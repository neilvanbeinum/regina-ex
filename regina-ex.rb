module ReginaEx
  class Test
    attr_reader :text, :to_match

    def initialize(text, to_match)
      @text = text
      @to_match = to_match
    end

    def evaluate(regex)
      if regex.match(@text).to_s == @to_match
        Result::Success.new(@to_match)
      else
        Result::Failure.new(@to_match)
      end
    end

    module Result
      class Failure
        def initialize(to_match)
          @to_match = to_match
        end

        def to_s
          "Did not match #{ @to_match }"
        end
      end

      class Success
        def initialize(to_match)
          @to_match = to_match
        end

        def to_s
          "Matched #{ @to_match }"
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
      @test_results.map(&:to_s)
    end

    def successful?
      @test_results.any? { |test_result| test_result.instance_of?(Test::Result::Success) }
    end
  end

  class Game
    require 'readline'

    def self.start_main_game_loop(levels)
      level = levels.shift

      puts "\n"
      puts 'WELCOME TO REGINA-EX!'
      puts "\n"

      loop do
        puts level.introduction_text
        puts '-' * level.introduction_text.length
        puts "\n"

        level.challenge_texts.each.with_index(1) { |challenge, i| puts "#{ i }. #{ challenge }" }

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
  ReginaEx::Level.new('Match the whole words.', [
    ReginaEx::Test.new('Embark!', 'Embark!'),
    ReginaEx::Test.new("Let's go!", "Let's go!"),
    ReginaEx::Test.new("Proceed!", "Proceed!")
  ]),
  ReginaEx::Level.new('Match the words beginning with a capital letter.', [
    ReginaEx::Test.new('One twO thRee', 'One'),
    ReginaEx::Test.new('oNe Two threE', 'Two'),
    ReginaEx::Test.new('onE two Three', 'Three'),
  ]),
  ReginaEx::Level.new('Match the continuous digits.', [
    ReginaEx::Test.new('aaaa1111aaaa', '1111'),
    ReginaEx::Test.new('aaa111aaa', '111'),
    ReginaEx::Test.new('aa11aa', '11'),
  ]),
  ReginaEx::Level.new("Match the 'a's followed by 'b's", [
    ReginaEx::Test.new('abaaab', 'ab'),
    ReginaEx::Test.new('aaa111aaa', ''),
    ReginaEx::Test.new('aa11aa', ''),
  ]),
]

ReginaEx::Game.start_main_game_loop(levels)
