# About

Web abb used for keeping score for `rentz` card game, also it will provide statistics about games, players and scores saved in the database.

It was created with Ruby on Rails using as database PostreSQL.
Version used are: Ruby 3.2.2 and Rails 7.0.8.

# Setup

1. Go to the RubyInstaller website https://rubyinstaller.org/ and download the appropriate RubyInstaller for your operating system.
2. Once the download is complete, run the RubyInstaller executable.
3. To verify that Ruby is installed correctly, open a terminal window and type the following command:
      ruby -v
4. To install Rails type in your terminal window the following command
      gem install rails -v 7.0.8
5. Go to the PostgreSQL website https://www.postgresql.org/download/ and download the appropriate PostgreSQL installer for your operating system.
6. Install bundler:
      gem install bundler
7. Install the project's dependencies:
      bundle install
8. Create and setup the database:
      rails db:create
      rails db:migrate
