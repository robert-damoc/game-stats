Rails.logger.info 'Started seeding games'
Game.states.each_value do |state|
  10.times { Game.create(state:) }
end

Rails.logger.info 'Started seeding players'
30.times { Player.create(name: Faker::Name.name) }

Rails.logger.info 'Done!'
