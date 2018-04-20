require 'pry'

# Your comment
class Player
  attr_accessor :name, :score

  NAMES = %w[r2d2 bob elisa].freeze
  MOVES = { 1 =>'rock', 2 => 'paper', 3 => 'scissors', 4 => 'lizard', 5 =>'spock' }

  def initialize(name)
    @name = name
  end

  def choose
    puts 'Enter a number 1-5 to make a selection: 1) Rock 2) Paper 3) Scissors 4) Lizard or 5)Spock'
  end
end

# Your comment
class Human < Player
  attr_accessor :move, :name

  def initialize
    @name = pick_a_name
    @score = Score.new
  end

  def choose
    super
    loop do
      choice = gets.chomp.to_i
      if !Player::MOVES[choice]
        puts 'Please enter a number 1-5 to make a selection: 1) Rock 2) Paper 3) Scissors 4) Lizard or 5)Spock'
        next
      else
        self.move = Player::MOVES[choice]
        puts "#{name} chose #{move}"
        break
      end
    end
  end

  private

  def pick_a_name
    puts 'What is your name'
    answer = nil
    loop do
      answer = gets.chomp
      break unless answer.empty?
      puts 'please make sure to enter a name'
    end
    answer
  end
end

# Your comment
class Computer < Player
  attr_accessor :move, :name
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
    if past.history[:human].empty?
      self.move = Player::MOVES[rand(6)]
    elsif !past.history[:human].group_by { |x| x.include?('w') }[true].nil?
        winning_moves = past.history[:human].group_by { |x| x.include?('w') }[true]
        frequently_occurring = analyze_history(winning_moves)
        self.move = WINNING_MOVES[frequently_occurring]
    end
    puts "#{name} chose #{move}"
  end

  def analyze_history(past)
    frequency = past.map { |el| past.count(el) }
    most_frequent_indicator = frequency.max
    index_of_max = frequency.index(most_frequent_indicator)
    past[index_of_max].sub('w', '')
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
    @history = { human: [], computer: [] }
  end

  def update_history(human_move, computer_move)
    history[:human] << human_move
    history[:computer] << computer_move
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

  def detect_win_condition
    MOVES.select { |x| human.move == x[0] && computer.move == x[1] }
  end

  def determine_winner
    if !!detect_win_condition
      human.name
    elsif human.move == computer.move
      'nobody'
    else
      computer.name
    end
  end

  def update_score
    if determine_winner == human.name
      human.score.update_score
    elsif determine_winner == computer.name
      computer.score.update_score
    end
  end

  def update_history
    if determine_winner == human.name
      history.update_history(human.move + 'w', computer.move)
    elsif determine_winner == computer.name
      history.update_history(human.move, computer.move + 'w')
    elsif determine_winner == 'nobody'
      history.update_history(human.move, computer.move)
    end
  end

  def display_winner
    winner = determine_winner
    if winner != 'nobody'
      puts "#{winner} wins: score is: h: #{human.score.tally} vs c: #{computer.score.tally}"
    else
      puts "It's a tie"
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
      update_score
      update_history
      display_winner
      break unless play_again?
    end
    display_goodbye_message
  end
end

game = RPSGame.new
game.play
