module ReginaEx
  class Challenge
    attr_reader :text, :to_match

    def initialize(text, to_match)
      @text = text
      @to_match = to_match
    end

    def evaluate(regex)
      if regex.match @to_match
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
end


def start_main_game_loop(levels)
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

    print '> '
    answer = gets.chomp

    answer_regex = Regexp.new(eval(answer))

    puts answer_regex

    result = level.attempt(answer_regex)

    puts "\n"
    puts result.challenge_result_text
    puts "\n"

    puts result.successful?

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

levels = [
  ReginaEx::Level.new('Match the whole words.', [
    ReginaEx::Challenge.new('Embark!', 'Embark!'),
    ReginaEx::Challenge.new("Let's go!", "Let's go!"),
    ReginaEx::Challenge.new("Proceed!", "Proceed!")
  ]),
  ReginaEx::Level.new('Match the words beginning with a capital letter.', [
    ReginaEx::Challenge.new('One two three', 'One'),
    ReginaEx::Challenge.new('one Two three', 'Two'),
    ReginaEx::Challenge.new('one two Three', 'Three'),
  ]),
]

start_main_game_loop(levels)
