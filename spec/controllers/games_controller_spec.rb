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
    end
  end
end
