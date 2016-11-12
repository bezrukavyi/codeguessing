module Codeguessing
  class Console
    attr_reader :game, :scores, :path

    RULES = [
      '-----------------Rules!----------------------',
      "You need guess secret code. This four-digit number with symbols from 1 to 6",
      "You have #{Game::MAX_ATTEMPTS} attempt(s) and #{Game::MAX_HINT} hint(s)",
      "If you want get hint write 'hint'",
      '---------------------------------------------'
    ]

    MESSAGE = {
      rules?: 'Do you know rules? (Y/N)',
      again?: 'Do you want start again? (Y/N)',
      save?: 'Do you want save result? (Y/N)',
      not_save: 'Maybe next time',
      set_name: 'Write your name',
      invalid_data: 'Invalid data',
      cant_save: 'You cant save game',
      loose_code: 'Secret code was',
      scores_line: {
        start: '-----------Scores----------',
        end: '---------------------------' },
      loose: 'You loose!',
      win: 'You win!'
    }

    def initialize
      @path = File.join(File.dirname(__FILE__), 'scores.yml')
      @scores = load(@path)
      @game = Game.new
    end

    def go(knowed = false)
      rules unless knowed
      puts "Attempt(s): #{@game.attempts} | Hint(s): #{@game.hint_count}"
      case @game.win?
      when true
        win
      when false
        loose
      else
        gaming
      end
    end

    def	rules
      puts MESSAGE[:rules?]
      unless confirm?
        puts RULES.join("\n")
      end
    end

    def gaming
      action = gets.chomp
      if action == 'hint'
        puts @game.hint
        return go(true)
      end
      if @game.valid?(action)
        puts @game.guess(action)
      else
        puts MESSAGE[:invalid_data]
      end
      go(true)
    end

    def confirm?(action = gets.chomp)
      return true if action.downcase == 'y'
      false
    end

    def load(path)
      YAML.load(File.open(path)) if File.exist?(path)
    end

    def save!(name = 'Anonim')
      return puts MESSAGE[:cant_save] unless @game.win?
      @scores << @game.cur_score(name.chomp)
      File.new(@path, 'w') unless File.exist?(@path)
      File.open(@path, "r+") do |f|
        f.write(@scores.to_yaml)
      end
      @scores
    end

    private

    def win
      puts MESSAGE[:win]
      save?
      again?
    end

    def loose
      puts MESSAGE[:loose]
      puts "#{MESSAGE[:loose_code]} #{@game.secret_code}"
      again?
    end

    def save?
      puts MESSAGE[:save?]
      return puts MESSAGE[:not_save] unless confirm?
      puts MESSAGE[:set_name]
      save!(gets)
    end

    def again?
      puts MESSAGE[:again?]
      if confirm?
        @game = Game.new
        return go(true)
      else
        puts MESSAGE[:scores_line][:start]
        p @scores
        puts MESSAGE[:scores_line][:end]
      end
    end

  end
end
