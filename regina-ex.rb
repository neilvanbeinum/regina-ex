module ReginaEx
  class Challenge
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

        def text
          "Did not match #{ @to_match }"
        end
      end

      class Success
        def initialize(to_match)
          @to_match = to_match
        end

        def text
          "Matched #{ @to_match }"
        end
      end
    end
  end

  class Level
    attr_reader :introduction_text

    def initialize(introduction_text, challenges)
      @introduction_text = introduction_text
      @challenges = challenges
    end

    def challenge_texts
      @challenges.each.map(&:text)
    end

    def attempt(regex)
      LevelResult.new(@challenges.map { |challenge| challenge.evaluate(regex) })
    end
  end

  class LevelResult
    def initialize(challenge_results)
      @challenge_results = challenge_results
    end

    def challenge_result_text
      @challenge_results.map(&:text)
    end

    def successful?
      @challenge_results.any? { |challenge_result| challenge_result.instance_of?(Challenge::Result::Success) }
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
          next
        end

        result = level.attempt(answer_regexp)

        puts "\n"
        puts result.challenge_result_text
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
    ReginaEx::Challenge.new('Embark!', 'Embark!'),
    ReginaEx::Challenge.new("Let's go!", "Let's go!"),
    ReginaEx::Challenge.new("Proceed!", "Proceed!")
  ]),
  ReginaEx::Level.new('Match the words beginning with a capital letter.', [
    ReginaEx::Challenge.new('One twO thRee', 'One'),
    ReginaEx::Challenge.new('oNe Two threE', 'Two'),
    ReginaEx::Challenge.new('onE two Three', 'Three'),
  ]),
  ReginaEx::Level.new('Match the continuous digits.', [
    ReginaEx::Challenge.new('aaaa1111aaaa', '1111'),
    ReginaEx::Challenge.new('aaa111aaa', '111'),
    ReginaEx::Challenge.new('aa11aa', '11'),
  ]),
  ReginaEx::Level.new("Match the 'a's followed by 'b's", [
    ReginaEx::Challenge.new('abaaab', 'ab'),
    ReginaEx::Challenge.new('aaa111aaa', ''),
    ReginaEx::Challenge.new('aa11aa', ''),
  ]),
]

ReginaEx::Game.start_main_game_loop(levels)
