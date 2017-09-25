require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  describe 'GET #new' do
    context 'when request format is HTML' do
      it 'redirects to `root_url`' do
        get :new
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when request format is JS' do
      it 'returns http success' do
        get :new, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'render `new`' do
        get :new, xhr: true
        expect(response).to render_template(:new)
      end

      it 'assigns @game' do
        get :new, xhr: true
        expect(assigns(:game)).not_to be_nil
      end

      it 'calls `Game.new` with the passed size' do
        expect(Game).to receive(:new).with('3')
        get :new, xhr: true, params: { size: 3 }
      end
    end
  end

  describe 'PUT #update' do
    context 'when request format is JS' do
      it 'returns http success' do
        allow_any_instance_of(Game).to receive(:update)
        put :update, xhr: true
        expect(response).to have_http_status(:success)
      end

      it 'render `update`' do
        allow_any_instance_of(Game).to receive(:update)
        put :update, xhr: true
        expect(response).to render_template(:update)
      end

      it 'assigns @game' do
        allow_any_instance_of(Game).to receive(:update)
        put :update, xhr: true
        expect(assigns(:game)).not_to be_nil
      end

      it 'calls `Game.new` with the passed size' do
        expect(Game).to receive(:new).with('3').and_call_original
        allow_any_instance_of(Game).to receive(:update)
        put :update, xhr: true, params: { size: 3 }
      end

      it 'calls `update` with the params' do
        expect_any_instance_of(Game).to receive(:update).with(kind_of(ActionController::Parameters))
        put :update, xhr: true, params: { size: 3 }
      end
    end
  end
end
