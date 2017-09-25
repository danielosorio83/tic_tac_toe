require 'rails_helper'

RSpec.describe Game, type: :model do
  # Accessors
  it { is_expected.to respond_to(:size) }

  let(:size) { 3 }
  let(:game) { Game.new(size) }

  describe 'Public Instance Methods' do
    describe '#initialize(size = 3)' do
      it 'setup a size' do
        expect(game.size).to eq(size)
      end
    end
  end
end