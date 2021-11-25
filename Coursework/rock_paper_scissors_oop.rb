class Move
  attr_reader :value, :defeats

  VALUES = ['rock', 'paper', 'scissors', 'lizard', 'spock']

  def >(other_move)
    defeats.include?(other_move.value)
  end

  def <(other_move)
    other_move.defeats.include?(value)
  end

  def self.return_subclass(choice)
    VALUES.each do |value|
      return Object.const_get(value.capitalize).new if choice == value
    end
    SuperMove.new(choice)
  end
end

class SuperMove < Move
  def initialize(value)
    @value = value
    @defeats = VALUES
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
    @defeats = ['lizard', 'scissors']
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
    @defeats = ['rock', 'spock']
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
    @defeats = ['paper', 'lizard']
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
    @defeats = ['spock', 'paper']
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
    @defeats = ['rock', 'scissors']
  end
end

class Player
  attr_accessor :move, :name, :score, :moves

  def initialize
    set_name
    @score = 0
    @moves = []
  end
end

class Human < Player
  attr_accessor :opponent, :defeat_code

  def initialize
    super
    @defeat_code = false
  end

  def set_name
    system('clear')
    n = nil
    loop do
      puts "=> What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, you must enter a value."
    end
    self.name = n
    system("clear")
  end

  def choose
    choice = nil
    loop do
      puts "=> Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice) || found_defeat_code?(choice)
      puts "Sorry, invalid choice."
    end
    puts "defeat_code found" if found_defeat_code?(choice)
    gets.chomp if found_defeat_code?(choice)

    robot_defeated! if found_defeat_code?(choice)
    self.moves << self.move = Move.return_subclass(choice)
    system("clear")
  end

  def robot_defeated!
    @defeat_code = true
  end

  def found_defeat_code?(choice)
    choice == self.opponent.defeat_code
  end
end

class Computer < Player
  attr_reader :move_percentages, :super_move, :defeat_code

  OPPONENTS = ['DarthVador', 'MetalGear', 'Alien', 'Predator', 'Terminator']

  def choose
    self.move = Move.return_subclass(weighted_choice)
    self.moves << self.move
  end

  def weighted_choice
    list_of_choices = []
    move_percentages.each do |move, percentage|
      percentage.times { list_of_choices << move}
    end

    list_of_choices.sample
  end
end

class DarthVador < Computer
  def initialize
    super
    @defeat_code = 'luke'
    @super_move = 'lightsaber'
    @move_percentages = { 'rock' => 20, 'paper' => 20, 'scissors' => 15,
                         'lizard' => 15, 'spock' => 20, 'lightsaber' => 10 }
  end

  def set_name
    @name = "Darth Vador"
  end
end

class MetalGear < Computer
  def initialize
    super
    @defeat_code = 'snake'
    @super_move = 'missiles'
    @move_percentages = { 'rock' => 30, 'paper' => 5, 'scissors' => 25,
                         'lizard' => 5, 'spock' => 15, 'missiles' => 20 }
  end

  def set_name
    @name = "Metal Gear"
  end
end

class Alien < Computer
  def initialize
    super
    @defeat_code = 'ripley'
    @super_move = 'cut-throat'
    @move_percentages = { 'rock' => 10, 'paper' => 5, 'scissors' => 25,
                         'lizard' => 35, 'spock' => 15, 'cut_throat' => 10 }
  end

  def set_name
    @name = "Alien"
  end
end

class Predator < Computer
  def initialize
    super
    @defeat_code = 'mud'
    @super_move = 'laser gun'
    @move_percentages = { 'rock' => 25, 'paper' => 15, 'scissors' => 25,
                         'lizard' => 5, 'spock' => 20, 'laser gun' => 10 }
  end

  def set_name
    @name = "Predator"
  end
end

class Terminator < Computer
  def initialize
    super
    @defeat_code = 'sarah conor'
    @super_move = 'shotgun'
    @move_percentages = { 'rock' => 15, 'paper' => 30, 'scissors' => 15,
                         'lizard' => 20, 'spock' => 10, 'shotgun' => 10 }
  end

  def set_name
    @name = "Terminator"
  end
end


# Game orchestration Engine
class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.const_get(Computer::OPPONENTS.sample).new
    human.opponent = computer
  end

  def display_welcome_message
    welcome_message = <<-MSG
    Welcome to Rock, Paper, Scissors, Lizard, Spock!

    Your opponent can use a secret move to defeat you easily at every round,
    but he cannot use it all the time.

    The good news is that you can also enter a hidden move to beat your
    opponent in one shot, the only problem is that you will have to
    figure it out yourself...

    Good luck!

    MSG
    puts welcome_message
    gets.chomp
    system('clear')
  end

  def reset_data
    human.score = 0
    computer.score = 0
    human.defeat_code = false
  end

  def display_moves
    puts "#{human.name} chose #{human.move.value} -- " +
      "#{computer.name} chose #{computer.move.value}."
  end

  def update_scores!
    if human.move > computer.move
      human.score += 1
    elsif human.move < computer.move
      computer.score += 1
    else
    end
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move < computer.move
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_scores
    puts "#{human.name} : #{human.score} | #{computer.name} : #{computer.score}"
  end

  def champion
    return human if human.score == 3
    return computer if computer.score == 3
  end

  def game_continues?
    (human.score < 3 && computer.score < 3) && !(human.defeat_code)
  end

  def display_champion
    puts "--"
    puts "And the champion is #{champion.name}!" if champion
  end

  def ultimate_win
    system('clear')
    puts "Congratulations for finding the secret code!"
    puts "You are the champion!"
    puts "#{human.name} : 10 | #{computer.name} : #{computer.score}"
  end

  def play_again?
    answer = nil
    loop do
      puts "Do you want to play again?"
      answer = gets.chomp
      break if answer.start_with?('y', 'n', 'Y', 'N')
      puts "Sorry, must be yes or no."
    end
    system('clear')
    return true if answer.start_with?('Y', 'y')
    return false if answer.start_with?('N', 'n')
  end

  def display_all_moves
    all_moves = human.moves.zip(computer.moves)

    all_moves.map!.with_index do |sub, idx|
      "Round #{idx + 1} -- #{human.name}: #{sub[0].value}" +
        " -- #{computer.name}: #{sub[1].value}"
    end

    all_moves.each { |round| puts round }
    puts
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock! Goodbye! "
  end

  def play
    display_welcome_message
    loop do
      reset_data
      loop do
        human.choose
        computer.choose
        display_moves
        update_scores!
        display_winner
        display_scores
        break unless game_continues?
      end
      human.defeat_code ? ultimate_win : display_champion
      break unless play_again?
    end
    display_all_moves
    display_goodbye_message
  end
end

RPSGame.new.play
#
# =begin
# IMPROVEMENTS
#
# When the player finds the secret code and the boss picks his super move, we can still
# see that the boss wins a point...
#
# When we want to play again, we should find a way to alter the boss, until we played every boss?
# Maybe we should give the option to pick the boss (do you want to change boss or play the same?)
#
# find a shortcut when picking a move
# =end
