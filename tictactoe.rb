require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = build_board
  end

  def build_board
    board = {}
    board_positions = (1..9).to_a
    board_positions.each { |position| board[position] = Square.new(' ') }
    board
  end

  def dup
    positions = {}
    duped_board = Board.new
    self.squares.map {|square| positions[square[0]] = Square.new(square[1].marker) }
    duped_board.squares = positions
    duped_board
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
    return true if available == 0
    false
  end

  def positions_remaining
    positions = []
    squares.select { |k,v| positions << k if v.marker == ' '}.to_a
  end

  def join_positions
    positions = positions_remaining
    last = positions[-1] 
    positions[-1] = 'or'
    positions.<<(last)
    sentence = connector_method(positions)
  end
  
  def connector_method(positions)
   count = 0
   list = []
   loop do 
     break if count == positions.count
     check = positions[count]
     list << check[0] unless check[0].class == String
     list << check if check[0].class == String
     count += 1
   end 
   list.join(", ")
  end 

  def winning_marker
    win = nil
    WINNING_LINES.each do |line|
      if line.select { |pos| squares[pos].marker == 'X' }.count == 3
        win = 'X'
      elsif line.select { |pos| squares[pos].marker == 'O' }.count == 3
        win = 'O'
      else 
        nil
      end
    end
    win
  end

  protected

  attr_accessor :squares

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
  attr_accessor :score, :name, :best_choice

  def initialize(name)
    @name = name
    @score = Score.new
    @best_choice = nil
  end

  def to_s
    @name
  end

  def minimax(board, current_player, depth=1)
    return scored(board, depth) if game_over?(board) && depth >= 2 #terminal state is reached start resolving stack frames  

    scores = {}

    board.dup.positions_remaining.each do |position|   
      virtual_board = board.dup
      virtual_board.set_position(position[0], current_player)
      scores[position[0]] = minimax(virtual_board, switch(current_player), depth + 1)
    end

    @best_choice, best_score = best_move(current_player, scores)

    best_score  # actual return value
  end

  def game_over?(board)
    board.winning_marker || board.full?
  end

  def best_move(player, scores)
    if player == 'O'
      scores.max_by { |_, v| v }
    elsif player == 'X'
      scores.min_by { |_, v| v }
    end
  end

  def scored(board , depth)
    if board.winning_marker == 'O'
      return 10 - depth
    elsif board.winning_marker == 'X'
      return depth - 10
    end
    0
  end

  def switch(player)
    player == 'O' ? 'X' : 'O'
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
    @player_turn = 'human'
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
    puts "Choose a position on the board from #{board.join_positions}"
    move = nil
    loop do
      move = gets.chomp.to_i
      break if (1..9).include?(move) && board.position_available?(move)
      puts "sorry, you must choose a position from #{board.join_positions}"
    end
    board.set_position(move, 'X')
  end

  def second_player_moves
    move = @computer.minimax(board, 'O', 1)
    board.set_position(@computer.best_choice, 'O')

    puts 'Computer Moved'
  end
 
  def someone_won?
    !!board.winning_marker
  end

  def display_winner
    if board.winning_marker == 'X'
      self.winner = "#{human}"
    elsif board.winning_marker == 'O'
      self.winner = "#{computer}"
    end
    puts "#{winner} wins the game!"
  end

  def update_score
    return if board.winning_marker.nil?
    board.winning_marker == 'X' ? human.score.increment : computer.score.increment
  end

  def play_again?
    puts 'Do you want to play again? y/n'
    answer = gets.chomp
  end

  def alternate_player
    self.player_turn = (player_turn == 'human' ? 'computer' : 'human')
  end

  def turn
     case player_turn
      when 'human'
        first_player_moves
      when 'computer'
        second_player_moves
     end
    alternate_player
    display_board
  end

  def final_state?
    board.full? || someone_won?
  end

  def play
    display_board

    loop do
      break if human.score.tally == 5 || computer.score.tally == 5

      if final_state?
         @board = Board.new
         answer = play_again?
         answer == 'y' ? play : break
      end
      
      turn
      update_score
    end

    display_winner
    display_goodbye_message
  end

end

game = TTTGame.new
game.display_welcome_message
game.play
