require 'rails_helper'

describe 'Players' do
  describe 'GET /players' do
    subject(:get_players) { get players_path, params: }

    let(:assigned_players) { assigns(:players) }
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

    context 'when there are no players' do
      let(:pagy_page) { 1 }
      let(:pagy_count) { 0 }
      let(:pagy_in) { 0 }

      before { get_players }

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_players).to be_empty }
      it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
    end

    context 'when providing invalid page number' do
      let(:params) { { page: 2 } }

      before { create_list(:player, 2) }

      it do
        expect { get_players }.to raise_error(Pagy::OverflowError)
      end
    end

    context "when there are more than #{Pagy::DEFAULT[:items]} players" do
      let(:players_count) { Pagy::DEFAULT[:items] + 1 }

      before do
        create_list(:player, players_count)

        get_players
      end

      context 'without explicit page number' do
        let(:pagy_page) { 1 }
        let(:pagy_count) { players_count }
        let(:pagy_in) { Pagy::DEFAULT[:items] }

        it { expect(response).to have_http_status(:ok) }
        it { expect(assigned_players.size).to be Pagy::DEFAULT[:items] }
        it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
      end

      context 'with explicit page number' do
        let(:params) { { page: 2 } }

        let(:pagy_page) { 2 }
        let(:pagy_count) { players_count }
        let(:pagy_in) { players_count - Pagy::DEFAULT[:items] }

        it { expect(response).to have_http_status(:ok) }
        it { expect(assigned_players.size).to be pagy_in }
        it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
      end
    end

    context "when there are less than #{Pagy::DEFAULT[:items]} players" do
      let(:players_count) { Pagy::DEFAULT[:items] - 1 }

      let(:pagy_page) { 1 }
      let(:pagy_count) { players_count }
      let(:pagy_in) { players_count }

      before do
        create_list(:player, players_count)

        get_players
      end

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_players.size).to be players_count }
      it { expect(assigned_pagy.as_json).to include(expected_pagy_vars) }
    end
  end

  describe 'GET /players/:id' do
    subject(:get_player) { get player_path(id) }

    let(:assigned_player) { assigns(:player) }

    before { get_player }

    context 'when player exists' do
      let(:actual_player) { create(:player) }
      let(:id) { actual_player.id }

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_player).to eq actual_player }
    end

    context 'when id is not UUID' do
      let(:id) { '1' }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_player).to be_nil }
    end

    context 'when player does not exist' do
      let(:id) { SecureRandom.uuid }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_player).to be_nil }
    end
  end

  describe 'GET /players/new' do
    subject(:get_new_player) { get new_player_path }

    let(:assigned_player) { assigns(:player) }

    before { get_new_player }

    it { expect(response).to have_http_status(:ok) }
    it { expect(assigned_player).to be_a Player }
  end

  describe 'GET /players/:id/edit' do
    subject(:get_edit_player) { get edit_player_path(id) }

    let(:assigned_player) { assigns(:player) }

    before { get_edit_player }

    context 'when player exists' do
      let(:actual_player) { create(:player) }
      let(:id) { actual_player.id }

      it { expect(response).to have_http_status(:ok) }
      it { expect(assigned_player).to eq actual_player }
    end

    context 'when id is not UUID' do
      let(:id) { '1' }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_player).to be_nil }
    end

    context 'when player does not exist' do
      let(:id) { SecureRandom.uuid }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(assigned_player).to be_nil }
    end
  end

  describe 'DELETE /players/:id' do
    subject(:delete_player) { delete player_path(id) }

    let(:assigned_player) { assigns(:player) }

    context 'when player exists' do
      let(:actual_player) { create(:player) }
      let(:id) { actual_player.id }

      it do
        actual_player

        aggregate_failures do
          expect { delete_player }.to change(Player, :count).by(-1)
          expect { assigned_player.reload }.to raise_error(ActiveRecord::RecordNotFound)
          expect(flash[:notice]).to eq 'Player was successfully destroyed.'
        end
      end

      it do
        delete_player
        expect(response).to have_http_status(:found)
      end

      it do
        delete_player
        expect(assigned_player).to eq actual_player
      end
    end

    context 'when id is not UUID' do
      let(:id) { '1' }

      it do
        expect { delete_player }.not_to change(Player, :count)
      end

      it do
        delete_player
        expect(response).to have_http_status(:not_found)
      end

      it do
        delete_player
        expect(assigned_player).to be_nil
      end
    end

    context 'when player does not exist' do
      let(:id) { SecureRandom.uuid }

      it do
        expect { delete_player }.not_to change(Player, :count)
      end

      it do
        delete_player
        expect(response).to have_http_status(:not_found)
      end

      it do
        delete_player
        expect(assigned_player).to be_nil
      end
    end
  end
end
