Game.states.each do |state|
  10.times do
    Game.create(state: state)
  end
end

30.times do
  Player.create(name: Faker::Name.name)
end
