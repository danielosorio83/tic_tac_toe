class Game
  attr_accessor :size, :table_size, :player, :table, :movements

  NEUTRO    = '-'
  PLAYER_1  = 'X'
  PLAYER_2  = 'O'
  PLAYERS   = [PLAYER_1, PLAYER_2]

  def initialize(initial_size = 3)
    self.size = initial_size
    self.table_size = size * size
    self.player = PLAYERS.sample
    self.table = Array.new(table_size, NEUTRO)
    self.movements = []
    move(initial_position) if player == PLAYER_2
  end

  def move(position)
    self.table[position] = player
    self.player = other_player
    self.movements << position
    self
  end

  private

  def initial_position
    size == 3 ? 4 : 0
  end

  def other_player
    player == PLAYER_1 ? PLAYER_2 : PLAYER_1
  end
end