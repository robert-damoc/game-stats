# Game-stats

## About

Web aplication used for keeping score of `rentz` card game, also it will provide statistics about games, players and scores saved in the database.

It was created with Ruby on Rails using as database PostreSQL.
Version used are: Ruby 3.2.2 and Rails 7.0.8.

## Setup

1. Go to the [RubyInstaller website](https://rubyinstaller.org/). Download the appropriate RubyInstaller for your operating system an folow the instalion steps.
2. To verify that Ruby is installed correctly, open a terminal window and type the following command:
    ```
    ruby -v
    ```
3. To install Rails type in your terminal window the following command
    ```
    gem install rails -v 7.0.8
    ```
4. Go to the [PostgreSQL website](https://www.postgresql.org/download/). Download the appropriate PostgreSQL installer for your operating system and folow the instalation steps.
5. Install bundler:
```
gem install bundler
```
6. Install the project's dependencies:
```
bundle install
```
7. Create and setup the database:
```
rails db:create
rails db:migrate
```
8. Open server:
```
rails s
```
9. Open application in browser at: [Game-stats](http://localhost:3000)

## Instructions

1. Create players. Enter the players page: http://localhost:3000/players and create players that will play the game.
2. Create game. Enter the games page: http://localhost:3000/games and create a game also adding the players to the game.
3. Start the game. Click on play icon on actions column.
4. Start inserting rounds from `+` icon on the scores table.
5. Input score on every round by editing the round on the score table.
6. Complete or cancel the game by clicking the corresponding icons on actions column
