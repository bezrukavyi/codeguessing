module Codeguessing
  class Console
    attr_reader :game, :scores, :path

    MESSAGE = YAML.load_file(File.join(File.dirname(__FILE__), 'data/messages.yml'))

    def initialize
      @path = File.join(File.dirname(__FILE__), 'data/scores.yml')
      @scores = load(@path) || []
      @game = Game.new
    end

    def	rules
      puts MESSAGE['rules?']
      puts MESSAGE['rules'].join("\n") unless confirm?
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
      puts game.valid?(action) ? game.guess(action) : MESSAGE['invalid_data']
      go(true)
    end

    private

    def confirm?(action = gets.chomp)
      action.downcase == 'y'
    end

    def load(path)
      YAML.load_file(path) if File.exist?(path)
    end

    def save(name = 'Anonim')
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
        puts_with_line(scores)
      end
    end

    def puts_with_line(message)
      puts MESSAGE['scores_line']['start']
      p message
      puts MESSAGE['scores_line']['end']
    end

  end
end
