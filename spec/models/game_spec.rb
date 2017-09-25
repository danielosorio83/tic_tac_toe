require 'rails_helper'

RSpec.describe Game, type: :model do
  # Accessors
  it { is_expected.to respond_to(:size) }
  it { is_expected.to respond_to(:table_size) }
  it { is_expected.to respond_to(:player) }
  it { is_expected.to respond_to(:table) }
  it { is_expected.to respond_to(:movements) }

  let(:size) { 3 }
  let(:game) { Game.new(size) }

  describe 'Public Instance Methods' do
    describe '#initialize(initial_size = 3)' do
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

      it 'setup a movements' do
        allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_1)
        expect(game.movements).to eq([])
      end

      context 'when `player` is `PLAYER_2`' do
        it 'call `move`' do
          allow(Game::PLAYERS).to receive(:sample).and_return(Game::PLAYER_2)
          expect_any_instance_of(Game).to receive(:move)
          game
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
  end
end