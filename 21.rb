require 'pry'
# Here is an overview of the game:
# - The player takes the first turn, and can "hit" or "stay".
# - If the player busts, he loses. If he stays, it's the dealer's turn.
# - The dealer must hit until his cards add up to at least 17.

# - If he busts, the player wins. If both player and dealer stays, then the highest total wins.
# - If both totals are equal, then it's a tie, and nobody wins.

module Hand
    def score_hand(player)
      player.hand.each do |card| 
        if %w(2 3 4 5 6 7 8 9 10).include?(card[1])
          player.total += card[1].to_i
        elsif %w(J Q K).include?(card[1])
          player.total += 10
        elsif card[1] == 'A'
          player.total > 17 ? player.total += 1 : player.total += 11
        end
      end
      player.total
    end

    def bust?(player) 
      return true if player.total > 21
    end

    def stayed?(player)
      return true if player.stayed == true 
    end 

end 

class Deck
  attr_accessor :deck
  def initialize 
    @deck = create_deck
  end 

   def create_deck
      suits = ['S', 'D', 'C', 'H']
      values = ['A','2', '3', '4', '5', '6', '7', '8', '9','10','J', 'Q', 'K']
      deck = []
       for suit in suits
        for value in values 
          deck << [suit, value]
        end 
       end 
      deck.shuffle! 
   end 
end

class Player
  attr_accessor :total

   def initialize
     @total = 0
   end  

   def hit; end 

   def stay; end 
 
end

class Dealer < Player
  attr_accessor :deck, :hand, :stayed, :total
  include Hand

  def initialize
    @deck = Deck.new.deck
    @hand = initial_deal
    @total = 0
    @stayed = false
  end

  def deal 
    deck.pop
  end 

  def initial_deal
    deck.pop(2)
  end 

  def hit 
    hand << deal
  end
 
  def stay
    :stay
  end

  def play
    total < 17 ? hit : stay
  end 

end

class Participant < Player
  attr_accessor :hand, :stayed, :total
  include Hand

  def initialize(hand)
    @hand = hand
    @total = 0
    @stayed = false
  end

  def choose 
    puts 'Do you want to hit or stay? 1) hit 2) stay'
    choice = gets.chomp
    if choice == '1'
      return :hit
    else
      return :stay
    end 
  end 

  def hit(card)
    hand << card
  end

  def stay
    stayed = true
    puts 'Participant chose to stay'
  end 
end

class Game
  attr_accessor :player_turn, :dealer, :participant, :busted
  include Hand

  def initialize
    @dealer = Dealer.new
    @participant = Participant.new(dealer.initial_deal)
    @player_turn = 'participant'
    @busted = false
  end

  def turn
    case player_turn
    when 'participant'
      choice = participant.choose
      if choice == :hit 
        participant.hit(dealer.deal)
      elsif choice == :stay
        participant.stayed = true
        participant.stay
      end 
    when 'dealer'
      dealer.play
    end  
  end

  def corrected_player
   player_turn == 'participant' ? participant : dealer
  end

#WishList: handle both player turns in game engine without duplicating code
  def game_engine
    loop do
      turn
      score_hand(corrected_player)
      break if bust?(corrected_player)
      self.player_turn = 'dealer' if stayed?(participant) 
      break if stayed?(participant) && stayed?(dealer) #winning condition
    end
    puts "someone won"
    #announce the player that wins
  end

end

play = Game.new 
play.game_engine

#notes 
#what is the technical reason for why I can't add 1 to nil ?
#why is the value instantiated in the initialize for the super class not set for sub classes also ?


