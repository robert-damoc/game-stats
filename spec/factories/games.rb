FactoryBot.define do
  factory :game do
    trait :created do
      state { 'created' }
    end

    trait :in_progress do
      state { 'in_progress' }
    end

    trait :completed do
      state { 'completed' }
    end

    trait :canceled do
      state { 'canceled' }
    end
  end
end
