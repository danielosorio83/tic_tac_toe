class Game
  attr_accessor :size, :table, :player, :movements, :table_size

  NEUTRO    = '-'
  PLAYER_1  = 'X'
  PLAYER_2  = 'O'
  PLAYERS   = [PLAYER_1, PLAYER_2]

  def initialize(size = 3)
    self.size = size.to_i
    self.table_size = @size * @size
    self.player = PLAYERS.sample
    self.table = Array.new(table_size, NEUTRO)
    self.movements = []
    move(initial_position) if player == PLAYER_2
  end

  def update(params)
    self.player = params[:player]
    self.table = params[:table]
    move(params[:position].to_i)
    auto_move unless end?
  end

  def win?(cell_player)
    winning_lines.any? do |line|
      line.all? { |line_cell| line_cell == cell_player }
    end
  end

  def blocked?
    winning_lines.all? do |line|
      line.any? { |line_cell| line_cell == PLAYER_1 } && line.any? { |line_cell| line_cell == PLAYER_2 }
    end
  end

  def end?
    win?(PLAYER_1) || win?(PLAYER_2) || @table.count(NEUTRO) == 0
  end

  private

  def initial_position
    size == 3 ? 4 : 0
  end

  def move(position)
    self.table[position] = player
    self.player = other_player
    self.movements << position
    self
  end

  def other_player
    player == PLAYER_1 ? PLAYER_2 : PLAYER_1
  end

  def auto_move
    move(best_move)
  end

  def best_move
    available_positions.send(best_move_operation_by_player) { |position| minimax(position) }
  end

  def available_positions
    table.map.with_index { |player_in_cell, position| player_in_cell == NEUTRO ? position : nil }.compact
  end

  def winning_lines
    (
      (0..table_size.pred).each_slice(size).to_a +
      (0..table_size.pred).each_slice(size).to_a.transpose +
      [ (0..table_size.pred).step(size.succ).to_a ] +
      [ (size.pred..(table_size-size)).step(size.pred).to_a ]
    ).map { |line| line.map { |position| table[position] }}
  end

  def minimax(position = nil)
    move(position) if position
    leaf_value = evaluate_leaf
    return leaf_value if leaf_value
    available_positions_operation
  ensure
    unmove if position
  end

  def evaluate_leaf
    return  100 if win?(PLAYER_1)
    return -100 if win?(PLAYER_2)
    return    0 if blocked?
  end

  def available_positions_operation
    available_positions.map do |position|
      minimax(position).send(minimax_operation_by_player, movements.count + 1)
    end.send(possible_move_operation_by_player)
  end

  def unmove
    self.table[movements.pop.to_i] = NEUTRO
    self.player = other_player
    self
  end

  def minimax_operation_by_player
    player == PLAYER_1 ? :- : :+
  end

  def possible_move_operation_by_player
    player == PLAYER_1 ? :max : :min
  end

  def best_move_operation_by_player
    player == PLAYER_1 ? :max_by : :min_by
  end
end