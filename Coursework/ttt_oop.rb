require "pry"

module PlayingOrder
  def reassign_playing_order(marker1, marker2)
    @playing_order = set_playing_order(marker1, marker2).cycle
    reset_current_playing_order
  end

  def set_playing_order(marker1, marker2)
    case @order_type
    when 1 then [[marker1, marker2].cycle]
    when 2 then [[marker2, marker1].cycle]
    when 3 then [[marker2, marker1].cycle, [marker1, marker2].cycle]
    end
  end

  def reset_current_playing_order
    @current_playing_order = @playing_order.next
    @current_playing_order.rewind
    @first_player = @current_playing_order.next
  end
end

class Board
  attr_reader :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def [](key)
    @squares[key].marker
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def display_board_pattern
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
  end

  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    display_board_pattern
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    display_board_pattern
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  "
    puts "     |     |"
  end

  def unmarked_keys
    squares.select { |_, sqr| sqr.unmarked? }.keys
  end

  def full?
    unmarked_keys.empty?
  end

  def winner_marker?(marker)
    WINNING_LINES.any? { |line| line.all? { |key| self[key] == marker } }
  end

  def find_line_with_2(marker)
    WINNING_LINES.find do |line|
      line.count { |key| self[key] == marker } == 2 &&
        line.count { |key| self[key] == Square::EMPTY_MARKER } >= 1
    end
  end

  def find_empty_square(line)
    line ? line.find { |key| self[key] == Square::EMPTY_MARKER } : nil
  end

  def empty_square(number)
    self[number] == Square::EMPTY_MARKER ? number : nil
  end
end

class Square
  EMPTY_MARKER = " "

  attr_accessor :marker

  def initialize(marker = EMPTY_MARKER)
    @marker = marker
  end

  def unmarked?
    marker == EMPTY_MARKER
  end

  def to_s
    @marker
  end
end

class Player
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end

  def reset_score
    @score = 0
  end
end

class Human < Player
  attr_reader :name, :marker
  attr_accessor :score

  def initialize
    @name = ask_human_name
    @marker = ask_human_marker
    @score = 0
  end

  def ask_human_name
    answer = nil
    loop do
      puts "What's your name?"
      answer = gets.chomp.capitalize
      break unless answer.empty?
      puts "Please enter a name."
    end
    answer
  end

  def ask_human_marker
    answer = nil
    puts "Choose a character to be your marker. Cannot be 'O'."
    loop do
      answer = gets.chomp.upcase
      break if answer.size == 1 && answer != 'O'
      puts "Please choose a character. Cannot be 'O'."
    end
    answer
  end
end

class Computer < Player
  attr_reader :name

  NAMES = ['Big Boss', 'Thanos', 'Darth Vador', 'Alien']

  def initialize(marker)
    super
    @name = NAMES.sample
  end
end

class TTTGame
  include PlayingOrder

  attr_reader :board, :human, :computer, :markers

  WINNING_POINTS = 5

  WHO_BEGINS_MESSAGE = <<-MSG
Decide who plays first:

1) You

2) The computer

3) The computer and you alternatively

(Pick 1, 2 or 3)
MSG

  RULES_MESSAGE = <<-MSG

The rules are simple:

=> You must align three squares before your opponent does to win one round.

=> The first player who reaches #{WINNING_POINTS} points wins the game.

(Press enter to continue)

MSG

  COMPUTER_MARKER = "O"

  def initialize
    clear
    @board = Board.new
    @human = Human.new
    @computer = Computer.new(COMPUTER_MARKER)
    @markers = [human.marker, COMPUTER_MARKER]
  end

  def play
    clear
    display_welcome_message
    main_game
    display_goodbye_message
  end

  private

  def clear
    system 'clear'
  end

  def display_welcome_message
    puts "WELCOME TO TIC TAC TOE!"
    display_rules_message
    display_who_begins_message
  end

  def display_rules_message
    puts RULES_MESSAGE
    gets.chomp
  end

  def display_who_begins_message
    puts WHO_BEGINS_MESSAGE
  end

  def main_game
    loop do
      board.reset
      reset_all_scores
      ask_order
      reassign_playing_order(human.marker, COMPUTER_MARKER)
      round_game
      display_champion_or_exit_message
      break unless play_again?
    end
  end

  def reset_all_scores
    human.reset_score
    computer.reset_score
  end

  def ask_order
    clear
    answer = nil
    display_who_begins_message
    loop do
      answer = gets.chomp.to_i
      break if [1, 2, 3].include? answer
      puts "Sorry, that's not a valid choice"
      display_who_begins_message
    end
    @order_type = answer
  end

  def round_game
    loop do
      player_moves
      update_scores
      display_result
      break if champion?(human.score) || champion?(computer.score) || exit_round?
      reset
    end
  end

  def exit_round?
    puts "(Enter 'x' to quit)"
    answer = gets.chomp.downcase
    answer == 'x'
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_board
    puts "#{human.name}, you're a #{human.marker}.
      #{computer.name} is a #{computer.marker}."
    puts ""
    display_scores
    puts ""
    board.draw
    puts ""
  end

  def player_moves
    loop do
      current_player_moves
      break if someone_won? || board.full?
      alternate_first_player
      clear_screen_and_display_board
    end
  end

  def current_player_moves
    @first_player == human.marker ? human_moves : computer_moves
  end

  def human_moves
    clear_screen_and_display_board
    puts "Choose a square: #{joinor(board.unmarked_keys)}"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    moves = [board.empty_square(5), find_opportunity,
             find_threat, board.unmarked_keys.sample]

    moves.each do |move|
      board[move] = computer.marker if move
      break if move
    end
  end

  def find_opportunity
    board.find_empty_square(board.find_line_with_2(COMPUTER_MARKER))
  end

  def find_threat
    board.find_empty_square(board.find_line_with_2(human.marker))
  end

  def alternate_first_player
    @first_player = @current_playing_order.next
  end

  def winner_marker
    @markers.each { |marker| return marker if board.winner_marker?(marker) }
    nil
  end

  def someone_won?
    !!winner_marker
  end

  def update_scores
    case winner_marker
    when human.marker then human.score += 1
    when computer.marker then computer.score += 1
    end
  end

  def display_result
    display_winner
    display_scores
  end

  def display_winner
    clear_screen_and_display_board
    case winner_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def display_scores
    puts "#{human.name}: #{human.score} | #{computer.name}: #{computer.score}"
  end

  def champion?(score)
    score == WINNING_POINTS
  end

  def display_champion_or_exit_message
    if champion?(human.score)
      puts "And the champion is #{human.name}!"
    elsif champion?(computer.score)
      puts "And the champion is the #{computer.name}!!"
    else
      clear
      puts "So sad to see you leave..."
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end
    answer == 'y'
  end

  def reset
    board.reset
    reset_current_playing_order
    clear
  end

  def display_goodbye_message
    clear
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def joinor(array, separator = ",", logical_word = "or")
    if array.size == 1
      "#{array.first}"
    elsif array.size == 2
      "#{array.first} #{logical_word} #{array.last}"
    else
      "#{array[0..-2].join(separator)} #{logical_word} #{array.last}"
    end
  end
end

# we'll kick off the game like this
game = TTTGame.new
game.play
