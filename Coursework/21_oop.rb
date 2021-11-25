class Card
  SUITS = %w(S C H D)
  FACES = ('2'..'10').to_a + %w(J Q K A)
  VALUES = Hash[FACES.zip((2..10).to_a + [10, 10, 10, 11])]
  SECRET_CARD = ["┌─────────┐",
                 "│░░░░░░░░░│",
                 "│░░░░░░░░░│",
                 "│░░░░░░░░░│",
                 "│░░░░░░░░░│",
                 "│░░░░░░░░░│",
                 "└─────────┘"]

  attr_reader :face, :suit
  attr_accessor :value

  def initialize(suit, face)
    @suit = suit
    @face = face
    @value = VALUES[face]
  end

  def color
    case suit
    when 'S' then "\u2660"
    when 'H' then "\u2665"
    when 'C' then "\u2663"
    when 'D' then "\u2666"
    end
  end

  def ace?
    face == "A"
  end
end

class Deck
  attr_accessor :cards

  def initialize
    reset
  end

  def reset
    @cards = Card::SUITS.product(Card::FACES).map { |c| Card.new(c[0], c[1]) }
    scramble!
  end

  def scramble!
    cards.shuffle!
  end

  def deal_one!(hand)
    card = cards.pop
    hand << card
    hand.add_column(card)
    hand.increment_total(card)
  end

  def deal_four!(hand, hand2)
    [hand, hand2].each do |h|
      2.times { deal_one!(h) }
    end
  end
end

class Player
  attr_reader :hand, :name
  attr_accessor :score

  def initialize
    @hand = Hand.new
    @score = 0
  end

  def busted?
    hand.total > TwentyOne::MAX_TOTAL
  end

  def won?(other_player)
    hand.total > other_player.hand.total && !busted?
  end
end

class Human < Player
  def initialize
    super
    @name = ask_name
  end

  def ask_name
    system 'clear'
    answer = nil
    puts "What's your name?"
    loop do
      answer = gets.chomp
      break unless answer.empty?
      system 'clear'
      puts "You have to pick something!"
    end
    answer
  end
end

class Dealer < Player
  ROBOTS = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5']

  def initialize
    @name = ROBOTS.sample
    super
  end

  def stays?
    hand.total >= TwentyOne::MAX_TOTAL - 4
  end
end

class Hand
  attr_reader :cards, :rows
  attr_accessor :total

  def initialize
    reset
  end

  def reset
    @cards = []
    @rows = [[], [], [], [], [], [], []]
    @total = 0
  end

  def display
    rows.each { |row| puts row.join("  ") }
  end

  def display_with_secret
    result = rows.map.with_index do |row, ix|
      row.map.with_index { |column, i| i == 0 ? Card::SECRET_CARD[ix] : column }
    end

    result.each { |row| puts row.join("  ") }
  end

  def <<(card)
    cards << card
  end

  # rubocop:disable Metrics/AbcSize
  def add_column(card)
    f1, f2 = face_displays(card)
    rows[0] << "┌─────────┐"
    rows[1] << "│#{f1}       │"
    rows[2] << "│         │"
    rows[3] << "│    #{card.color}    │"
    rows[4] << "│         │"
    rows[5] << "│       #{f2}│"
    rows[6] << "└─────────┘"
  end
  # rubocop:enable Metrics/AbcSize

  def increment_total(card)
    self.total += card.value
    adjust_for_aces
  end

  private

  def adjust_display(card)
    [card.face + " ", card.face.rjust(2, " ")]
  end

  def face_displays(card)
    card.face != '10' ? adjust_display(card) : [card.face, card.face]
  end

  def adjust_for_aces
    return unless total > TwentyOne::MAX_TOTAL && cards.any?(&:ace?)
    cards.each { |card| card.value = 1 if card.ace? }
    self.total = cards.inject(0) { |sum, card| sum + card.value }
  end
end

class TwentyOne
  MAX_TOTAL = 21
  WINNING_SCORE = 5

  WELCOME_MESSAGE = <<-MSG
WELCOME TO #{MAX_TOTAL}!

#{MAX_TOTAL} is a cards game. You will play against the dealer. The goal is for you to
have a better score than the dealer, whithout going over #{MAX_TOTAL} points. The player
that gets more than #{MAX_TOTAL} points will 'BUST' and lose the round.

Once you get your first two cards, you can choose to 'HIT' another card or 'STAY'
if you think you can beat the dealer.

You will need to win #{WINNING_SCORE} rounds to win the game.

Press 'enter' to continue
MSG

  RULES_MESSAGE = <<-MSG
POINTS:

- 2:    2 points     |     - 10:       10 points
- 3:    3 points     |     - jack:     10 points
- 4:    4 points     |     - queen:    10 points
- 5:    5 points     |     - king:     10 points
- 6:    6 points     |
- 7:    7 points     |     - ace:      11 points if your total score is below #{MAX_TOTAL},
- 8:    8 points     |                  1 point if your total score is above #{MAX_TOTAL}.
- 9:    9 points     |

Press 'enter' to start.
MSG

  HIT_OR_STAY_MESSAGE = <<-MSG

=> Would you like to:

   1) Hit
   2) Stay
MSG

  def start
    display_welcome_message
    game
    display_goodbye
  end

  private

  attr_reader :deck, :human, :dealer

  def initialize
    @deck = Deck.new
    @human = Human.new
    @dealer = Dealer.new
  end

  def display_welcome_message
    clear
    puts WELCOME_MESSAGE
    pause
    clear
    puts RULES_MESSAGE
    pause
  end

  def game
    loop do
      deck.deal_four!(human.hand, dealer.hand)
      display_shuffling
      display_board
      main_game
      break if champion || ask_play_again == 'x'
      reset
    end
  end

  def display_shuffling
    clear
    puts "The dealer is shuffling the cards"
    2.times do
      print "."
      sleep(1)
    end
  end

  def display_scores
    clear
    puts "#{human.name.upcase}: #{human.score} ***** "\
      "#{dealer.name.upcase}: #{dealer.score}"
  end

  def display_human_hand
    puts
    puts "   #{human.name.upcase}'S CARDS"
    puts
    human.hand.display
  end

  def display_dealer_hand
    puts
    puts "   #{dealer.name.upcase}'S CARDS"
    puts
    dealer.hand.display_with_secret
  end

  def display_hands_and_total
    display_human_hand
    display_dealer_hand
    puts
    puts "Your current total is #{human.hand.total}."
  end

  def display_board
    display_scores
    display_hands_and_total
  end

  def main_game
    dealer_plays if human_plays == :stays
    display_end
  end

  def human_plays
    loop do
      ask_hit_or_stay == '1' ? human_hits : (return :stays)
      return :busted! if human.busted?
    end
  end

  def ask_hit_or_stay
    puts HIT_OR_STAY_MESSAGE
    answer = nil
    loop do
      puts
      answer = gets.chomp
      break if ['1', '2'].include?(answer)
      puts "That's not a valid choice. Pick 1 or 2."
    end
    answer
  end

  def dealer_plays
    display_dealer_hits
    loop do
      break if dealer.stays? || dealer.busted?
      deck.deal_one!(dealer.hand)
      clear
      display_board
      sleep(1)
    end
  end

  def human_hits
    display_human_hits
    deck.deal_one!(human.hand)
    display_board unless dealer.stays?
  end

  def update_scores
    if human.won?(dealer) || dealer.busted?
      human.score += 1
    elsif dealer.won?(human) || human.busted?
      dealer.score += 1
    end
  end

  def display_human_hits
    display_board
    puts
    print "You hit"
    sleep(1)
    clear
  end

  def display_dealer_hits
    display_board
    puts
    puts "You stay, #{dealer.name}'s turn..."
    2.times do
      print "."
      sleep(1)
    end
  end

  def champion
    return human.name if human.score == WINNING_SCORE
    return dealer.name if dealer.score == WINNING_SCORE
    nil
  end

  def display_round_end
    display_scores
    display_all_hands
    display_all_totals
    display_round_result
  end

  def display_all_hands
    puts
    puts "   #{human.name.upcase}'S CARDS:"
    puts
    human.hand.display
    puts
    puts "   #{dealer.name.upcase}'S CARDS:"
    puts
    dealer.hand.display
  end

  def display_all_totals
    puts
    puts "Your current total is #{human.hand.total}."
    puts "The dealer current total is #{dealer.hand.total}."
    puts
  end

  # rubocop:disable Metrics/MethodLength
  def display_round_result
    if dealer.busted?
      puts "Dealer busted! You won!"
    elsif human.busted?
      puts "You busted! Dealer won!"
    elsif human.won?(dealer)
      puts "You won!"
    elsif dealer.won?(human)
      puts "You lost"
    else
      puts "It's a tie"
    end
  end
  # rubocop:enable Metrics/MethodLength

  def display_champion
    puts
    puts "And the grand champion is #{champion.upcase}!"
    pause
  end

  def display_end
    update_scores
    display_round_end
    display_champion if champion
  end

  def ask_play_again
    answer = nil
    loop do
      puts
      puts "Press enter to play the next round, enter 'x' to quit the game."
      answer = gets.chomp.downcase
      break if answer.empty? || answer == 'x'
      puts "That is not a valid choice."
    end
    answer
  end

  def reset
    deck.reset
    human.hand.reset
    dealer.hand.reset
  end

  def display_goodbye
    clear
    puts "Thanks for playing #{MAX_TOTAL}, see you soon!"
    puts
  end

  def clear
    system 'clear'
  end

  def pause
    gets.chomp
  end
end

TwentyOne.new.start
