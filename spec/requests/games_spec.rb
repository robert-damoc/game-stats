require 'rails_helper'

describe 'Games' do
  describe 'GET /games' do
    subject(:get_games) { get games_path, params: }

    let(:assigned_games) { assigns(:games) }
    let(:assigned_pagy) { assigns(:pagy) }
    let(:params) { {} }
    let(:expected_pagy_vars) do
      {
        page: pagy_page,
        items: Pagy::DEFAULT[:items],
        count: pagy_count,
        in: pagy_in
      }.with_indifferent_access
    end

    context 'when there are no games' do
      let(:pagy_page) { 1 }
      let(:pagy_count) { 0 }
      let(:pagy_in) { 0 }

      before { get_games }

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_games).to be_empty }
      it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
    end

    context 'when providing invalid page number' do
      let(:params) { { page: 2 } }

      before { create_list(:game, 2) }

      it { expect { get_games }.to raise_error(Pagy::OverflowError) }
    end

    context "when there are more than #{Pagy::DEFAULT[:items]} games" do
      let(:games_count) { Pagy::DEFAULT[:items] + 1 }

      before do
        create_list(:game, games_count)

        get_games
      end

      context 'without explicit page number' do
        let(:pagy_page) { 1 }
        let(:pagy_count) { games_count }
        let(:pagy_in) { Pagy::DEFAULT[:items] }

        it { expect(response).to have_http_status(:ok) }
        it { expect(assigned_games.size).to be Pagy::DEFAULT[:items] }
        it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
      end

      context 'with explicit page number' do
        let(:params) { { page: 2 } }

        let(:pagy_page) { 2 }
        let(:pagy_count) { games_count }
        let(:pagy_in) { games_count - Pagy::DEFAULT[:items] }

        it { expect(response).to have_http_status(:ok) }
        it { expect(assigned_games.size).to be pagy_in }
        it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
      end
    end

    context "when there are less than #{Pagy::DEFAULT[:items]} games" do
      let(:games_count) { Pagy::DEFAULT[:items] - 1 }

      let(:pagy_page) { 1 }
      let(:pagy_count) { games_count }
      let(:pagy_in) { games_count }

      before do
        create_list(:game, games_count)

        get_games
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_games.size).to be games_count }
      it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
    end
  end

  describe 'GET /games/:id' do
    subject(:get_game) { get game_path(id) }

    let(:assigned_game) { assigns(:game) }
    let(:assigned_player_totals) { assigns(:player_totals) }

    before { get_game }

    context 'when game exists' do
      let(:game) { create(:game) }
      let(:id) { game.id }

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_game).to eq game }
      it { expect(assigned_player_totals).to be_empty }

      it 'calculates player totals correctly' do
        game.game_players.each do |player|
          expect(assigned_player_totals[player.id]).to eq(player_total_score(game, player))
        end
      end
    end

    context 'when id is not UUID' do
      let(:id) { '1' }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_game).to be_nil }
      it { expect(assigned_player_totals).to be_nil }
    end

    context 'when game does not exist' do
      let(:id) { SecureRandom.uuid }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_game).to be_nil }
      it { expect(assigned_player_totals).to be_nil }
    end
  end

  describe 'GET /games/new' do
    subject(:get_new_game) { get new_game_path }

    let(:assigned_game) { assigns(:game) }

    before { get_new_game }

    it { expect(response).to have_http_status(:ok) }
    it { expect(assigned_game).to be_a Game }
  end
end
