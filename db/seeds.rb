Game.states.each_value do |state|
  10.times { Game.create(state:) }
end

30.times { Player.create(name: Faker::Name.name) }
