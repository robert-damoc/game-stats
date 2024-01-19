require 'rails_helper'

describe 'Players' do
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

      before do
        create_list(:game, 2)
      end

      it do
        expect { get_games }.to raise_error(Pagy::OverflowError)
      end
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
end

