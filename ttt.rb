require 'pry'

# Your comment
class Player
  attr_accessor :name, :score

  NAMES = %w[r2d2 bob elisa].freeze
  MOVES = %w[rock paper scissors lizard spock]

  def initialize(name)
    @name = name
  end

  def choose
    puts 'Choose either Rock Paper Scissors Lizard or Spock'
  end
end

# Your comment
class Human < Player
  attr_accessor :move

  def initialize
    @name = pick_a_name
    @score = Score.new
  end

  def choose
    super
    loop do
      choice = gets.chomp
      if !Player::MOVES.include? choice
        puts 'Please choose either rock paper or scissors'
        next
      else
        self.move = choice
        puts "#{name} chose #{choice}"
        break
      end
    end
  end

  private

  def pick_a_name
    puts 'What is your name'
    answer = gets.chomp
  end
end

# Your comment
class Computer < Player
  attr_accessor :move
  WINNING_MOVES = { 'rock' => 'paper',
                    'paper' => 'scissors',
                    'scissors' => 'rock',
                    'spock' => 'paper', 
                    'lizard' => 'scissors' }.freeze

  def initialize
    super(Player::NAMES.sample)
    @score = Score.new
  end

  def choose(past)
    if past.history[:h].empty?
      self.move = Player::MOVES.sample
    elsif
      winning_moves = past.history[:h].group_by { |x| x.include?('w') }
      if !winning_moves[true].nil?
        frequency = winning_moves[true].map { |el| winning_moves[true].count(el) }
        most_frequent_indicator = frequency.max
        index_of_max = frequency.index(most_frequent_indicator)
        frequently_occurring = winning_moves[true][index_of_max].sub('w', '')
        self.move = WINNING_MOVES[frequently_occurring]
      else
        self.move = Player::MOVES.sample
      end
    end
    puts "#{name} chose #{move}"
  end
end

# Your comment
class Score
  attr_accessor :tally, :history

  def initialize
    @tally = 0
  end

  def update_score
    self.tally += 1
  end
end

# Your comment
class MoveHistory
  attr_accessor :history

  def initialize
    @history = { h: [], c: [] }
  end

  def update_history(human_move, computer_move)
    history[:h] << human_move
    history[:c] << computer_move
  end
end

# Your comment
class RPSGame
  attr_accessor :human, :computer, :rounds, :history
  MOVES = [['rock','scissors'], ['scissors', 'paper'], ['paper', 'rock'], ['rock', 'lizard'], ['spock', 'scissors'], ['scissors', 'lizard'], ['lizard', 'paper'], ['paper', 'spock'], ['spock', 'rock']]
  def initialize
    @rounds = 1
    @human = Human.new
    @computer = Computer.new
    @history = MoveHistory.new
  end

  def display_welcome_message
    puts 'Welcome to Rock Paper Scissors Lizard Spock'
  end

  def display_goodbye_message
    puts 'Thanks for playing Rock Paper Scissors Lizard Spock'
  end

  def detect
    moves.select { |x| human.move == x[0] && computer.move == x[1] }
  end

  def compare
    if !!detect
      human.name
    elsif human.move == computer.move
      'nobody'
    else
      computer.name
    end
  end

  def display_winner
    if compare == human.name
      human.score.update_score
      history.update_history(human.move + 'w', computer.move)
      puts "#{human.name} wins: score is: h: #{human.score.tally} vs c: #{computer.score.tally}"
    elsif compare == computer.name
      computer.score.update_score
      history.update_history(human.move, computer.move + 'w')
      puts "#{computer.name} wins: score is: c: #{computer.score.tally} vs h: #{human.score.tally}"
    elsif compare == 'nobody'
      puts "It's a tie"
      history.update_history(human.move, computer.move)
    end
  end

  def play_again?
    puts 'Would you like to play again. Type y or n'
    answer = nil
    loop do
      answer = gets.chomp
      break if %w[y n].include? answer.downcase
      puts 'Sorry you have to choose y or n'
    end
    if answer == 'y' && @rounds < 10
      @rounds += 1
      return true
    end

    return false if answer == 'n'
  end

  def play
    display_welcome_message
    loop do
      puts "Round: #{@rounds}"
      human.choose
      computer.choose(history)
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

game = RPSGame.new
game.play
