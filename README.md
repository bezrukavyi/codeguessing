# Codeguessing

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'codeguessing'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codeguessing

## Usage

```ruby
require 'codeguessing'
Codeguessing::Console.new.go # Console game
Codeguessing::Game.new # Game model
```
## Telegram Bot

[Bot](https://telegram.me/CodeguessingBot)

## Game's rules
You need guess secret code. This FOUR-digit number(guess) with symbols from 1 to 6
You have 5 attempt(s) and 2 hint(s)
A '+' indicates an exact match: one of the numbers in the guess is the same as one of the numbers in the secret code and in the same position.
A '-' indicates a number match: one of the numbers in the guess is the same as one of the numbers in the secret code but in a different position.
A empty answer means that you nothing guessed
If you want get hint write or click on keyboard 'hint'
If you want start game write or click on keyboard 'new game'
