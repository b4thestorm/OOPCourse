require 'pry'
# board
class Board
  attr_accessor :squares
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]
  def initialize
    @squares = build_board
  end

  def build_board
    board = {}
    board_positions= (1..9).to_a
    board_positions.each { |position| board[position] = Square.new(' ') }
    board
  end

  def position_at(pos)
    squares[pos]
  end

  def set_position(pos, mark)
    self.squares[pos].marker = mark
  end

  def position_available?(pos)
    return false if squares[pos].marker == 'X' || squares[pos].marker == 'O'
    true
  end

  def full?
    available = squares.select { |k, v| v.marker == ' ' }.count
    available == 0 ? true : false
  end

  def positions_remaining
    positions = []
    squares.select { |k,v| positions << k if v.marker == ' '}
    join_or(positions)
  end

  def join_or(positions)
    last = positions[-1] 
    positions[-1] = 'or'
    positions.<<(last)
    positions.join(", ")
  end
end

# cells
class Square
  attr_accessor :marker

  def initialize(marker)
    @marker = marker
  end

  def to_s
    marker
  end
end

# main player
class Player
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

# player type
class Human < Player
  attr_accessor :score, :name
  def initialize
    @name = set_name
    @score = Score.new
  end

  def set_name
    puts 'Please enter your player name:'
    answer = nil
    loop do
      answer = gets.chomp
      break unless answer == ' '
      puts 'Sorry, you have to choose a name'
    end
    answer
  end

  def to_s
    @name
  end
end

# player type
class Computer < Player
  attr_accessor :score, :name
  def initialize(name)
    @name = name
    @score = Score.new
  end

  def to_s
    @name
  end

end

# score class
class Score
  attr_accessor :tally
  def initialize(tally = 0)
    @tally = tally
  end

  def increment
    self.tally += 1
  end
end

# game engine
class TTTGame
  attr_accessor :board, :human, :computer, :winner, :player_turn
  def initialize
    @board = Board.new
    @human = Human.new
    @computer = Computer.new('r2d2')
    @winner = nil
    @player_turn = ''
  end

  def display_welcome_message
    puts 'Welcome to Tic Tac Toe'
    puts ' '
  end

  def clear
    system 'clear'
  end

  def display_board
    clear
    puts ''
    puts '     |     |     '
    puts "  #{board.position_at(1)}  |   #{board.position_at(2)} |   #{board.position_at(3)}  "
    puts '     |     |     '
    puts '-----+-----+-----+'
    puts '     |     |     '
    puts "   #{board.position_at(4)} |   #{board.position_at(5)} |   #{board.position_at(6)}  "
    puts '     |     |     '
    puts '-----+-----+-----+'
    puts '     |     |     '
    puts "   #{board.position_at(7)} |   #{board.position_at(8)} |  #{board.position_at(9)}   "
    puts '     |     |     '
  end

  def display_goodbye_message
    puts 'Thanks for playing'
  end

  def first_player_moves
    puts "Choose a position on the board from #{board.positions_remaining}"
    move = nil
    loop do
      move = gets.chomp.to_i
      break if (1..9).include?(move) && board.position_available?(move)
      puts "sorry, you must choose a position from #{board.positions_remaining}"
    end
    board.set_position(move, 'X')
  end

  def second_player_moves
    move = nil
    loop do
      move = (1..9).to_a.sample
      break board.set_position(move, 'O') if board.position_available?(move)
    end
    puts 'Computer Moved'
  end

#TODO finish implementing minimax algorithm
  def minimax(new_board, player)
     available_spots = board.positions_remaining
     if winning(new_board, 'human')
      score = -10
     elsif winning(new_board, 'computer')
      score = 10
     else available_spots == 0
       score = 0 
     end
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    win = nil
    Board::WINNING_LINES.each do |line|
      if line.select { |pos| board.squares[pos].marker == 'X' }.count == 3
        win = 'X'
      elsif line.select { |pos| board.squares[pos].marker == 'O' }.count == 3
        computer.tally.increment
        win = 'O'
      end
      nil
    end
    win
  end

  def display_winner
    if winning_marker == 'X'
      self.winner = "#{human}"
    elsif winning_marker == 'O'
      self.winner = "#{computer}"
    end
    puts "#{winner} wins the game!"
  end

  def update_score
    if winning_marker == 'X'
      human.score.increment
    elsif winning_marker == 'O'
      computer.score.increment
    end
  end

  def play_again?
    puts 'Do you want to play again? y/n'
    answer = gets.chomp
  end

  def alternate_player
    if player_turn == 'human'
      self.player_turn = 'computer'
      first_player_moves
      display_board
    elsif player_turn == 'computer'
      self.player_turn = 'human'
      second_player_moves
      display_board
    end
  end

  def play
    display_welcome_message
    display_board
    self.player_turn = 'human'
    loop do
      break if human.score.tally == 5 || computer.score.tally == 5
      alternate_player
      if board.full? || someone_won?
        self.player_turn = 'human'
        update_score
        @board = Board.new
        answer = play_again?
        answer == 'y' ? next : break
      end
    end
    display_winner
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
