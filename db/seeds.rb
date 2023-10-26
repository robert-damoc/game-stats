puts 'Started seeding Games'
Game.states.each_value do |state|
  games_to_create = 10 - Game.where(state:).count
  games_to_create.times { Game.create(state:) } if games_to_create.positive?
end

puts 'Started seeding Players'
(30 - Player.count).times { Player.create(name: Faker::Name.name) }

puts 'Started seeding GamePlayers'
Game.find_each do |game|
  players = Player.order('RANDOM()').limit(3)

  players.each do |player|
    game.game_players.create(player:)
  end
end

puts 'Started seeding Rounds'
GamePlayer.find_each do |game_player|
  Round.round_types.keys.sample(3).each do |round_type|
    game_player.rounds.create(round_type:)
  end
end

puts 'Done!'
