require 'rails_helper'

describe Player do
  describe '.allowed_sort_columns' do
    subject(:allowed_sort_columns) { described_class.allowed_sort_columns }

    it 'returns only the name' do
      expect(allowed_sort_columns).to match_array %w[name]
    end
  end

  describe '.default_sort_column' do
    subject(:default_sort_column) { described_class.default_sort_column }

    it 'returns only the name' do
      expect(default_sort_column).to eq 'name'
    end
  end

  describe 'validations' do
    context 'when validating the name presence' do
      context 'with name provided' do
        let(:player_name) { nil }

        it 'raises ActiveRecord::RecordInvalid' do
          expect { create(:player, name: player_name) }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'without name provided' do
        let(:player_name) { Faker::Lorem.characters(number: 15) }

        it 'does not raise error' do
          expect { create(:player, name: player_name) }.not_to raise_error
        end

        it 'creates the record' do
          expect { create(:player, name: player_name) }.to change(described_class, :count).by(1)
        end
      end
    end

    context 'when validating the name length' do
      context 'when length is bigger than 30' do
        let(:player_name) { Faker::Lorem.characters(number: 40) }

        it 'raises ActiveRecord::RecordInvalid' do
          expect { create(:player, name: player_name) }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when length is smaller than 30' do
        let(:player_name) { Faker::Lorem.characters(number: 20) }

        it 'does not raise error' do
          expect { create(:player, name: player_name) }.not_to raise_error
        end

        it 'creates the record' do
          expect { create(:player, name: player_name) }.to change(described_class, :count).by(1)
        end
      end
    end
  end
end
