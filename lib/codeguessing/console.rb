module Codeguessing
  class Console
    attr_reader :game, :scores, :path

    def initialize(opt = {})
      @path = File.join(File.dirname(__FILE__), 'scores.yml')
      @scores = load(@path)
      @game = Game.new(opt)
    end

    def go(know = true)
      rules if know
      puts "Attempt(s): #{@game.attempts} | Hint(s): #{@game.hint_count}"
      case @game.state
        when 'true'
          win
        when 'false'
          loose
        else
          gaming
      end
    end

    def	rules
      puts "Do you know rules? (Y/N)"
      rules = [
        '-----------------Rules!----------------------',
        "You need guess secret code. This four-digit number with symbols from 1 to 6",
        "You have #{@game.attempts} attempt(s) and #{@game.hint_count} hint(s)",
        "If you want get hint write 'hint'",
        '---------------------------------------------'
      ]
      unless confirm?
        puts rules.join("\n")
      end
    end

    def gaming
      action = gets.chomp
      if action == 'hint'
        puts @game.hint
        return go(false)
      end
      if @game.valid?(action)
        puts @game.guess(action)
      else
        puts 'Invalid data'
      end
      go(false)
    end

    def confirm?(action = gets.chomp)
      return true if action.downcase == 'y'
      false
    end

    def load(path)
      YAML.load(File.open(path)) if File.exist?(path)
    end

    def save!(name = 'Anonim')
      if @game.state != 'true'
        return puts 'You cant save game'
      end
      name.chomp!
      @scores << @game.cur_score(name)
      File.new(@path, 'w') unless File.exist?(@path)
      File.open(@path, "r+") do |f|
        f.write(@scores.to_yaml)
      end
      @scores
    end

    private

    def win
      puts 'You win!'
      save?
      again?
    end

    def loose
      puts 'You loose!'
      again?
    end

    def save?
      puts 'Do you want save result? (Y/N)'
      return puts 'Goodbie!' unless confirm?
      puts 'Write your name'
      save!(gets)
    end

    def again?
      puts 'Do you want start again? (Y/N)'
      if confirm?
        @game = Game.new
        return go(false)
      else
        puts '-----------Scores----------'
        p @scores
        puts '---------------------------'
      end
    end

  end
end
