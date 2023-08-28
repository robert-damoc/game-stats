# Rails.logger.info 'Started seeding games'
# Game.states.each_value do |state|
#   10.times { Game.create(state:) }
# end

# Rails.logger.info 'Started seeding players'
# 30.times { Player.create(name: Faker::Name.name) }

Rails.logger.info 'Started seeding gameplayers'
Game.find_each do |game|
  Player.all.sample(3).each do |player|
    GamePlayer.create!(game_id: game.id, player_id: player.id)
  end
end

Rails.logger.info 'Done!'
