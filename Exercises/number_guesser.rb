class GuessingGame
  MAX_GUESSES = 7

  RESULT_OF_GUESS_MESSAGE = {
    high: "Your number is too high.",
    low: "Your number is too low.",
    match: "That's the number!"
  }.freeze

  WIN_OR_LOSE = {
    high: :lose,
    low: :lose,
    match: :win
  }.freeze

  RESULT_OF_GAME_MESSAGE = {
    win: "You won!",
    lose: "You have no more guesses, you lost!"
  }.freeze

  def initialize(low_value, high_value)
    @secret_number = nil
    @range = (low_value..high_value)
  end

  def play
    reset
    game_result = play_game
    display_game_end_message(game_result)
  end

  private

  def reset
    @secret_number = rand(@range)
  end

  def play_game
    result = nil
    MAX_GUESSES.downto(1).each do |remaining_guesses|
      display_remaining_guesses(remaining_guesses)
      result = check_guess(obtain_one_guess)
      puts RESULT_OF_GUESS_MESSAGE[result]
      break if result == :match
    end
    WIN_OR_LOSE[result]
  end

  def display_remaining_guesses(remaining_guesses)
    if remaining_guesses > 1
      puts "You have #{remaining_guesses} guesses remaining."
    else
      puts "You have one guess remaining."
    end
  end

  def obtain_one_guess
    choice = nil
    loop do
      puts "Enter a number between #{@range.first} and #{@range.last}: "
      choice = gets.chomp.to_i
      return choice if @range === choice
      puts "Invalid guess."
    end
  end

  def check_guess(guess)
    if guess < @secret_number
      :low
    elsif guess > @secret_number
      :high
    else
      :match
    end
  end

  def display_game_end_message(result)
    puts RESULT_OF_GAME_MESSAGE[result]
  end

end

game = GuessingGame.new(501, 1500)
game.play
