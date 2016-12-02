module Codeguessing
  class Console
    attr_reader :game, :scores

    MESSAGE = YAML.load_file(File.absolute_path('data/messages.yml'))

    def initialize
      @path = File.absolute_path('data/scores.yml')
      @scores = load(@path)
      @game = Game.new
    end

    def	rules
      puts MESSAGE['rules?']
      unless confirm?
        puts MESSAGE['rules'].join("\n")
      end
    end

    def go(knowed = false)
      rules unless knowed
      puts "Attempt(s): #{game.attempts} | Hint(s): #{game.hint_count}"
      case game.win?
      when true then win
      when false then loose
      else gaming
      end
    end

    def gaming
      action = gets.chomp
      if action == 'hint'
        puts game.hint
        return go(true)
      end
      if game.valid?(action)
        puts game.guess(action)
      else
        puts MESSAGE['invalid_data']
      end
      go(true)
    end

    private

    def confirm?(action = gets.chomp)
      return true if action.downcase == 'y'
      false
    end

    def load(path)
      YAML.load_file(path) if File.exist?(path)
    end

    def save(name: 'Anonim', path: @path)
      return puts MESSAGE['cant_save'] unless game.win?
      @scores << game.cur_score(name.chomp)
      File.new(path, 'w') unless File.exist?(path)
      File.open(path, "r+") do |f|
        f.write(scores.to_yaml)
      end
      scores
    end

    def win
      puts MESSAGE['win']
      save?
      again
    end

    def loose
      puts MESSAGE['loose']
      puts "#{MESSAGE['loose_code']} #{game.secret_code}"
      again
    end

    def save?
      puts MESSAGE['save?']
      return puts MESSAGE['not_saved'] unless confirm?
      puts MESSAGE['set_name']
      save(gets)
    end

    def again
      puts MESSAGE['again?']
      if confirm?
        @game = Game.new
        return go(true)
      else
        puts MESSAGE['scores_line']['start']
        p scores
        puts MESSAGE['scores_line']['end']
      end
    end
  end
end
