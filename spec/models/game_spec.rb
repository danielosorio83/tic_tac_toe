require 'rails_helper'

RSpec.describe Game, type: :model do
  # Accessors
  it { is_expected.to respond_to(:size) }
  it { is_expected.to respond_to(:table) }
  it { is_expected.to respond_to(:player) }
  it { is_expected.to respond_to(:movements) }
  it { is_expected.to respond_to(:table_size) }

  let(:size) { 3 }
  let(:game) { Game.new(size) }

  describe 'Public Instance Methods' do
    describe '#initialize(size = 3)' do
      it 'setup a size' do
        expect(game.size).to eq(size)
      end

      it 'setup a new table size' do
        expect(game.table_size).to eq(size * size)
      end

      it 'setup a new table' do
        allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_1)
        expect(game.table).to eq(Array.new(game.table_size, Game::NEUTRO))
      end

      it 'setup a player' do
        expect(game.player).to be_in(Game::PLAYERS)
      end

      context 'when `player` is `PLAYER_2`' do
        it 'call `move`' do
          allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_2)
          expect_any_instance_of(Game).to receive(:move)
          game
        end
      end
    end

    describe '#update(params)' do
      let(:params) { { player: 'X', table: ['-', 'O', '-'], position: '1' } }
      before do
        allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_1)
      end

      it 'assigns player from params' do
        game.player = 'O'
        allow(game).to receive(:move)
        allow(game).to receive(:end?).and_return(true)
        game.update(params)
        expect(game.player).to eq('X')
      end

      it 'assigns table from params' do
        allow(game).to receive(:move)
        allow(game).to receive(:end?).and_return(true)
        expect(game.table).to eq(Array.new(game.table_size, Game::NEUTRO))
        game.update(params)
        expect(game.table).to eq(params[:table])
      end

      it 'calls `move` with `params[:position]' do
        allow(game).to receive(:end?).and_return(true)
        expect(game).to receive(:move).with(params[:position].to_i)
        game.update(params)
      end

      context 'when `end?` is FALSE' do
        it 'calls `auto_move`' do
          allow(game).to receive(:move)
          allow(game).to receive(:end?).and_return(false)
          expect(game).to receive(:auto_move)
          game.update(params)
        end
      end

      context 'when `end?` is TRUE' do
        it 'never calls `auto_move`' do
          allow(game).to receive(:move)
          allow(game).to receive(:end?).and_return(true)
          expect(game).to receive(:auto_move).never
          game.update(params)
        end
      end
    end

    describe '#win?(player)' do
      it 'returns falsy for all the players' do
        Game::PLAYERS.each do |player|
          expect(game.win?(player)).to be_falsy
        end
      end

      it 'determines a win for PLAYER_1' do
        game.table = %w(X X X
                        - - -
                        - O O)
        expect(game.win?('X')).to be_truthy
      end

      it 'determines a win for PLAYER_2' do
        game.table = %w(X X -
                        - - -
                        O O O)
        expect(game.win?('O')).to be_truthy
      end
    end

    describe '#blocked?' do
      it 'returns false for initial table' do
        expect(game.blocked?).to be_falsy
      end

      it 'returns true when all cells are used' do
        game.table = %w(X O X
                        O X X
                        O X O)
        expect(game.blocked?).to be_truthy
      end
    end

    describe '#end?' do
      it 'returns false' do
        expect(game.end?).to be_falsy
      end

      context 'when PLAYER_1 won' do
        it 'returns true' do
          allow(game).to receive(:win?).with(Game::PLAYER_1).and_return(true)
          expect(game.end?).to be_truthy
        end
      end

      context 'when PLAYER_2 won' do
        it 'returns true' do
          allow(game).to receive(:win?).with(Game::PLAYER_1).and_return(false)
          allow(game).to receive(:win?).with(Game::PLAYER_2).and_return(true)
          expect(game.end?).to be_truthy
        end
      end

      context 'when no position available' do
        it 'returns true' do
          allow(game.table).to receive(:count).with(Game::NEUTRO).and_return(0)
          allow(game).to receive(:win?).with(Game::PLAYER_1).and_return(false)
          allow(game).to receive(:win?).with(Game::PLAYER_2).and_return(false)
          expect(game.end?).to be_truthy
        end
      end
    end
  end

  describe 'Private Instance Methods' do
    describe '#initial_position' do
      context 'when `size` is 3' do
        it 'returns 4' do
          expect(game.send(:initial_position)).to eq(4)
        end
      end

      context 'when `size` is 4' do
        let(:size) { 4 }

        it 'returns 0' do
          expect(game.send(:initial_position)).to eq(0)
        end
      end
    end

    describe '#move(position)' do
      let(:position) { 1 }

      it 'assigns `player` to table[position]' do
        current_player = game.player
        game.send(:move, position)
        expect(game.table[position]).to eq(current_player)
      end

      it 'change `player`' do
        current_player = game.player
        game.send(:move, position)
        expect(game.player).not_to eq(current_player)
      end

      it 'inserts position into `movements`' do
        game.send(:move, position)
        expect(game.movements).to include(position)
      end
    end

    describe '#other_player' do
      context 'when `player` is `PLAYER_1`' do
        it 'returns `PLAYER_2`' do
          game.player = Game::PLAYER_1
          expect(game.send(:other_player)).to eq(Game::PLAYER_2)
        end
      end

      context 'when `player` is `PLAYER_2`' do
        it 'returns `PLAYER_1`' do
          game.player = Game::PLAYER_2
          expect(game.send(:other_player)).to eq(Game::PLAYER_1)
        end
      end
    end

    describe '#auto_move' do
      it 'calls `move` with `best_move`' do
        best_move = 0
        expect(game).to receive(:best_move).and_return(best_move)
        expect(game).to receive(:move).and_return(best_move)
        game.send(:auto_move)
      end
    end

    describe '#best_move' do
      it 'returns the best move for the player X' do
        game.table = %w(X X -
                        - - -
                        - O O)
        game.player = 'X'
        expect(game.send(:best_move)).to eq(2)
      end
      it 'returns the best move for the player O' do
        game.table = %w(X X -
                        - - -
                        - O O)
        game.player = 'O'
        expect(game.send(:best_move)).to eq(6)
      end
    end

    describe '#available_positions' do
      let(:position) { 3 }

      before do
        allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_1)
      end

      it 'lists all available positions from initial table' do
        expect(game.send(:available_positions)).to eq((0..8).to_a)
      end
      it 'lists all available positions from table after a move' do
        game.send(:move, position)
        expect(game.send(:available_positions)).to eq((0..8).to_a - [position])
      end
    end

    describe '#winning_lines' do
      before do
        allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_1)
      end

      it 'find winning columns, rows, diagonals' do
        game.table = (0..8).to_a
        winning_lines = game.send(:winning_lines)
        expect(winning_lines).to include([0, 1, 2])
        expect(winning_lines).to include([3, 4, 5])
        expect(winning_lines).to include([6, 7, 8])
        expect(winning_lines).to include([0, 3, 6])
        expect(winning_lines).to include([1, 4, 7])
        expect(winning_lines).to include([2, 5, 8])
        expect(winning_lines).to include([0, 4, 8])
        expect(winning_lines).to include([2, 4, 6])
      end
    end

    describe '#minimax(position = nil)' do
      context 'when position is present' do
        let(:position) { 1 }

        it 'calls `move` with the argument' do
          allow(game).to receive(:available_positions_operation)
          expect(game).to receive(:move).with(position)
          allow(game).to receive(:unmove)
          game.send(:minimax, position)
        end

        it 'calls `unmove`' do
          allow(game).to receive(:available_positions_operation)
          allow(game).to receive(:move).with(position)
          expect(game).to receive(:unmove)
          game.send(:minimax, position)
        end
      end

      context 'when position is NOT present' do
        it 'never calls `unmove`' do
          allow(game).to receive(:available_positions_operation)
          expect(game).to receive(:unmove).never
          game.send(:minimax)
        end
      end

      it 'calls `evaluate_leaf`' do
        allow(game).to receive(:available_positions_operation)
        expect(game).to receive(:evaluate_leaf)
        game.send(:minimax)
      end

      context 'when `evaluate_leaf` is NOT nil' do
        let(:evaluate_leaf) { 100 }

        it 'returns `evaluate_leaf` when is not nil' do
          allow(game).to receive(:evaluate_leaf).and_return(evaluate_leaf)
          expect(game.send(:minimax)).to eq(evaluate_leaf)
        end

        it 'never calls `available_positions_operation`' do
          allow(game).to receive(:evaluate_leaf).and_return(evaluate_leaf)
          expect(game).to receive(:available_positions_operation).never
          game.send(:minimax)
        end
      end

      context 'when `evaluate_leaf` is nil' do
        it 'calls `available_positions_operation`' do
          allow(game).to receive(:evaluate_leaf).and_return(nil)
          expect(game).to receive(:available_positions_operation)
          game.send(:minimax)
        end
      end
    end

    describe '#evaluate_leaf' do
      it 'returns nil on initial table' do
        expect(game.send(:evaluate_leaf)).to be_nil
      end

      context 'when PLAYER_1 won' do
        it 'returns 100' do
          allow(game).to receive(:win?).with(Game::PLAYER_1).and_return(true)
          expect(game.send(:evaluate_leaf)).to eq(100)
        end
      end

      context 'when PLAYER_2 won' do
        it 'returns -100' do
          allow(game).to receive(:win?).with(Game::PLAYER_1).and_return(false)
          allow(game).to receive(:win?).with(Game::PLAYER_2).and_return(true)
          expect(game.send(:evaluate_leaf)).to eq(-100)
        end
      end

      context 'when blocked?' do
        it 'returns 0' do
          allow(game).to receive(:win?).with(Game::PLAYER_1).and_return(false)
          allow(game).to receive(:win?).with(Game::PLAYER_2).and_return(false)
          allow(game).to receive(:blocked?).and_return(true)
          expect(game.send(:evaluate_leaf)).to eq(0)
        end
      end
    end

    describe '#available_positions_operation' do
      before do
        allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_1)
      end
      it 'returns 99 for a winning position for player X' do
        game.table = %w(X X -
                        - - -
                        - O O)
        game.player = 'X'
        expect(game.send(:available_positions_operation)).to eq(99)
      end

      it 'returns -99 for a winning position for player O' do
        game.table = %w(X X -
                        - - -
                        - O O)
        game.player = 'O'
        expect(game.send(:available_positions_operation)).to eq(-99)
      end
    end

    describe '#unmove' do
      let(:position) { 1 }

      before do
        game.send(:move, position)
      end

      it 'change `table[position]` to NEUTRO' do
        expect(game.table[position]).not_to eq(Game::NEUTRO)
        game.send(:unmove)
        expect(game.table[position]).to eq(Game::NEUTRO)
      end

      it 'change `player`' do
        current_player = game.player
        game.send(:unmove)
        expect(game.player).not_to eq(current_player)
      end

      it 'pops `position` into `movements`' do
        expect(game.movements).to include(position)
        game.send(:unmove)
        expect(game.movements).not_to include(position)
      end
    end

    describe '#minimax_operation_by_player' do
      context 'when `player` is `PLAYER_1`' do
        it 'returns `:-`' do
          game.player = Game::PLAYER_1
          expect(game.send(:minimax_operation_by_player)).to eq(:-)
        end
      end

      context 'when `player` is `PLAYER_2`' do
        it 'returns `:+`' do
          game.player = Game::PLAYER_2
          expect(game.send(:minimax_operation_by_player)).to eq(:+)
        end
      end
    end

    describe '#possible_move_operation_by_player' do
      context 'when `player` is `PLAYER_1`' do
        it 'returns `:-`' do
          game.player = Game::PLAYER_1
          expect(game.send(:possible_move_operation_by_player)).to eq(:max)
        end
      end

      context 'when `player` is `PLAYER_2`' do
        it 'returns `:+`' do
          game.player = Game::PLAYER_2
          expect(game.send(:possible_move_operation_by_player)).to eq(:min)
        end
      end
    end

    describe '#best_move_operation_by_player' do
      context 'when `player` is `PLAYER_1`' do
        it 'returns `:-`' do
          game.player = Game::PLAYER_1
          expect(game.send(:best_move_operation_by_player)).to eq(:max_by)
        end
      end

      context 'when `player` is `PLAYER_2`' do
        it 'returns `:+`' do
          game.player = Game::PLAYER_2
          expect(game.send(:best_move_operation_by_player)).to eq(:min_by)
        end
      end
    end
  end
end
