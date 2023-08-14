10.times do
  Game.create(state: 'created')
end

10.times do
  Game.create(state: 'in_progress')
end

10.times do
  Game.create(state: 'completed')
end

10.times do
  Game.create(state: 'canceled')
end
