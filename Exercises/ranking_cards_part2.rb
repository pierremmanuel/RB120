class Card
  attr_reader :rank, :suit

  VALUES = { 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5,
             6 => 6, 7 => 7, 8 => 8, 9 => 9, 10 => 10,
             "Jack" => 11, "Queen" => 12, "King" => 13, "Ace" => 14 }

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def <=>(other)
    VALUES[rank] <=> VALUES[other.rank]
  end

  def ==(other)
    rank == other.rank && suit == other.suit
  end
end

class Deck
  RANKS = ((2..10).to_a + %w(Jack Queen King Ace)).freeze
  SUITS = %w(Hearts Clubs Diamonds Spades).freeze

  attr_reader :cards

  def initialize
    reset
  end

  def draw
    reset if cards.empty?
    cards.shift
  end

  private

  def reset
    @cards = RANKS.product(SUITS).map { |card| Card.new(card[0], card[1]) }
    @cards = @cards.shuffle!
  end
end


deck = Deck.new
puts deck.cards
puts "----"
drawn = []
52.times { drawn << deck.draw }

puts drawn.count { |card| card.rank == 5 } == 4
puts drawn.count { |card| card.suit == 'Hearts' } == 13

drawn2 = []
52.times { drawn2 << deck.draw }
puts drawn != drawn2 # Almost always.
