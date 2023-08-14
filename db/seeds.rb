10.times do |game|
  Game.create(state: "created")
end

10.times do |game|
  Game.create(state: "in_progress")
end

10.times do |game|
  Game.create(state: "completed")
end

10.times do |game|
  Game.create(state: "canceled")
end
