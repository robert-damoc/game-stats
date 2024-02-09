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

  describe 'GET /games/:id/edit' do
    subject(:get_edit_game) { get edit_game_path(id) }

    let(:assigned_game) { assigns(:game) }
    let(:assigned_player_totals) { assigns(:player_totals) }

    before { get_edit_game }

    context 'when game exists' do
      let(:actual_game) { create(:game) }
      let(:id) { actual_game.id }

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_game).to eq actual_game }
      it { expect(assigned_player_totals).to be_empty }
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

  describe 'POST /games' do
    subject(:create_game) { post games_path, params: }

    let(:assigned_game) { assigns(:game) }

    context 'when player_ids are empty' do
      let(:params) { { game: { player_ids: [] } } }

      it do
        aggregate_failures do
          expect { create_game }.to change(Game, :count).by(1)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(games_url)
          expect(flash.now[:notice]).to eq 'Game was successfully created.'
          expect(assigned_game.errors).to be_empty
          expect(assigned_game).to be_persisted
        end
      end
    end

    context 'when player_ids are invalid' do
      let(:params) { { game: { player_ids: ['invalid_id'] } } }

      it do
        aggregate_failures do
          expect { create_game }.not_to change(Game, :count)
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when player_ids are valid and within limit' do
      let(:valid_player_ids) { Array.new(Game::MAX_PLAYERS_PER_GAME) { create(:player).id } }
      let(:params) { { game: { player_ids: valid_player_ids } } }

      it do
        aggregate_failures do
          expect { create_game }.to change(Game, :count).by(1)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(games_url)
          expect(flash.now[:notice]).to eq 'Game was successfully created.'
          expect(assigned_game.errors).to be_empty
          expect(assigned_game).to be_persisted
        end
      end
    end

    context 'when player_ids exceed the limit' do
      let(:invalid_player_ids) { Array.new(Game::MAX_PLAYERS_PER_GAME + 1) { create(:player).id } }
      let(:params) { { game: { player_ids: invalid_player_ids } } }

      it do
        aggregate_failures do
          expect { create_game }.not_to change(Game, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(flash.now[:notice]).to eq(
            "There can be a maximum of #{Game::MAX_PLAYERS_PER_GAME} players in a game."
          )
          expect(assigned_game.errors.full_messages).to include(
            "Game players There can be a maximum of #{Game::MAX_PLAYERS_PER_GAME} players in a game."
          )
          expect(assigned_game).not_to be_persisted
        end
      end
    end
  end

  describe 'PUT /games/:id' do
    subject(:update_game) { put game_path(id), params: }

    let(:assigned_game) { assigns(:game) }
    let(:id) { create(:game).id }
    let(:new_state) { 'created' } # Replace with the actual valid state
    let(:params) { { game: { state: new_state, player_ids: updated_player_ids } } }
    let(:updated_player_ids) { [first_player, second_player] }
    let(:first_player) { create(:player).id }
    let(:second_player) { create(:player).id }

    before { update_game }

    context 'when params is empty' do
      it do
        aggregate_failures do
          expect(flash.now[:notice]).to eq 'Game was successfully updated.'
          expect(assigned_game.errors.full_messages).to be_empty
          expect(assigned_game.reload.state).to eq 'created'
          expect(response).to have_http_status(:found)
        end
      end
    end

    context 'when current state is in_progress' do
      let(:new_state) { 'in_progress' }

      context 'when there are less than MIN_PLAYERS_PER_GAME' do
        let(:updated_player_ids) { [] }

        it do
          aggregate_failures do
            expect(flash.now[:notice]).to eq(
              "Minimum number of players to start the game is #{Game::MIN_PLAYERS_PER_GAME}"
            )
            expect(assigned_game.errors[:game_players]).to include(
              "Minimum number of players to start the game is #{Game::MIN_PLAYERS_PER_GAME}"
            )
            expect(assigned_game.reload.state).to eq 'created'
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when the number of players is between MIN_PLAYERS_PER_GAME and MAX_PLAYERS_PER_GAME' do
        let(:updated_player_ids) { Array.new(Game::MIN_PLAYERS_PER_GAME + 1) { create(:player).id } }

        it do
          aggregate_failures do
            expect(response).to redirect_to(edit_game_url(assigned_game))
            expect(flash.now[:notice]).to eq 'Game was successfully updated.'
            expect(assigned_game.errors).to be_empty
            expect(assigned_game.reload.state).to eq 'in_progress'
            expect(assigned_game.players.pluck(:id)).to match_array(updated_player_ids)
            expect(response).to have_http_status(:found)
          end
        end
      end

      context 'when there are more than MAX_PLAYERS_PER_GAME' do
        let(:updated_player_ids) { Array.new(Game::MAX_PLAYERS_PER_GAME + 1) { create(:player).id } }

        it do
          aggregate_failures do
            expect(flash.now[:notice]).to eq(
              "There can be a maximum of #{Game::MAX_PLAYERS_PER_GAME} players in a game."
            )
            expect(assigned_game.errors[:game_players]).to include(
              "There can be a maximum of #{Game::MAX_PLAYERS_PER_GAME} players in a game."
            )
            expect(assigned_game.reload.state).to eq 'created'
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    context 'when state completed' do
      let(:new_state) { 'completed' }

      it do
        aggregate_failures do
          expect(flash.now[:notice]).to eq 'invalid state transition'
          expect(assigned_game.errors[:state]).to include('invalid state transition')
          expect(assigned_game.reload.state).not_to eq new_state
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when state is canceled' do
      let(:new_state) { 'canceled' }

      it do
        aggregate_failures do
          expect(response).to redirect_to(edit_game_url(assigned_game))
          expect(flash.now[:notice]).to eq 'Game was successfully updated.'
          expect(assigned_game.errors).to be_empty
          expect(assigned_game.reload.state).to eq new_state
          expect(response).to have_http_status(:found)
        end
      end
    end

    context 'when id is not UUID' do
      let(:id) { '1' }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_game).to be_nil }
    end

    context 'when game does not exist' do
      let(:id) { SecureRandom.uuid }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_game).to be_nil }
    end
  end
end
