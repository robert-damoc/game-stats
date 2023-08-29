Rails.logger.info 'Started seeding games'
Game.states.each_value do |state|
  games_to_create = Game.where(state:).count - 10
  games_to_create.times { Game.create(state:) } if games_to_create.positive?
end

Rails.logger.info 'Started seeding players'
(Player.count - 30).times { Player.create(name: Faker::Name.name) }

Rails.logger.info 'Started seeding gameplayers'
Game.find_each do |game|
  players = Player.order('RANDOM()').limit(3)

  players.each do |player|
    game.game_players.create(player:)
  end
end

Rails.logger.info 'Done!'
