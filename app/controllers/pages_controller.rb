class PagesController < ApplicationController
  before_action :authenticate_user!, except: %i[home hiscores invincible twoplayers games play registerplayers result playagain]
  before_action :initialize_plays, only: [:play]
  skip_before_action :verify_authenticity_token, only: [:twoplayers, :play, :registerplayers, :reset_board, :result, :playagain]

  def initialize_plays
    session[:plays] ||= 0
  end

  def home
  end

  def games
  end

  def hiscores
    @users = User.order(win: :desc)
  end

  def played
    current_user.win += 1 if params[:win]
    current_user.losses += 1 if params[:loss]
    current_user.ties += 1 if params[:tie]
    current_user.save
  end

  def invincible
  end
  
  def play
    cell = params[:cell]
    if session["cell_#{cell}"].present?
      render json: { success: false, message: '#{cell.inspect}' }
      return
    end
   
    session["cell_#{cell}"] = get_turn
    add_plays_count
    win = player_play_win(cell)
    
    if !win
      switch_turn
      current_player
      redirect_to twoplayers_path
    else
      
      mark_win(get_turn)
      reset_board
      redirect_to result_path
    end
  end

  def registerplayers
    session[:player_x_name] = params[:player1_name]
    session[:player_o_name] = params[:player2_name]
    set_turn('x')
    reset_board
    reset_wins
    current_player
    
    redirect_to twoplayers_path
  end
  
 def play_again
  set_turn('x')
  reset_board
  current_player
  redirect_to twoplayers_path
 end
  def twoplayers
     
  
  end

  def current_player
   session[:current_player] = get_player_name(get_turn) 
  end

 def get_player_name(player='x') 
    session["player_#{player}_name"]
 end
  
  private

  def reset_board
    reset_plays_count
    (1..9).each { |i| session.delete("cell_#{i}") }
  end

  def reset_wins
    session[:player_x_wins] = 0
    session[:player_o_wins] = 0
  end

  def reset_plays_count
    session[:plays] = 0
  end

  def plays_count
    session[:plays].to_i
  end

  def get_turn
    session[:turn] || 'x'
  end

  def set_turn(turn = 'x')
    session[:turn] = turn
  end

  def add_plays_count
    session[:plays] += 1
  end

  def player_play_win(cell = 1)
    return false if session[:plays] < 3
    column = cell % 3
    column = 3 if column.nil?
    row = (cell.to_f / 3.0).ceil
    player = get_turn
    is_vertical_win(column, player) || is_horizontal_win(row, player) || is_diagonal_win(player)
  end

  def mark_win(player = 'x')
    session["player_#{player}_wins"] ||= 0
    session["player_#{player}_wins"] += 1
  end

  def switch_turn
    set_turn(get_turn == 'x' ? 'o' : 'x')
  end

  def is_vertical_win(column = 1, turn = 'x')
    column = column.to_i
  newcell=1
  get_cell(newcell) == turn &&
    get_cell(newcell + 3) == turn &&
    get_cell(newcell + 6) == turn ||   get_cell(newcell+1) == turn &&
    get_cell(newcell + 4) == turn &&
    get_cell(newcell + 7) == turn ||   get_cell(newcell+2) == turn &&
    get_cell(newcell + 5) == turn &&
    get_cell(newcell + 8) == turn 
    
  end
  
  def is_horizontal_win(row = 1, turn = 'x')
    cell=1
    if row == 1
      cell = 1
    elsif row == 2
      cell = 4
    elsif row == 3
      cell = 7
    end
    get_cell(cell) == turn &&
      get_cell(cell + 1) == turn &&
      get_cell(cell + 2) == turn
  end
  
  def is_diagonal_win(turn = 'x')
    win = get_cell(1) == turn && get_cell(9) == turn

    unless win
      win = get_cell(3) == turn && get_cell(7) == turn
    end
  
    win && get_cell(5) == turn
  end

  def get_cell(cell = '')
    session["cell_#{cell}"]
  end

  def score(player = 'x')
    session["player_#{player}_wins"].presence || 0
  end

  def set_stats
    @wins = current_user.win
    @losses = current_user.losses
    @ties = current_user.ties
  end
end
