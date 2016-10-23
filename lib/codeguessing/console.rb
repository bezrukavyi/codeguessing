module Codeguessing
  class Console
    def initialize(again = false)
      @path = File.join(File.dirname(__FILE__), 'scores.yml')
      @data = load(@path)
      @game = Game.new(@data)
      return start if again
      knowing
    end

    def	knowing
      puts "Are you ready broke code? (Y/N)"
      if confirm?
        puts '-----------------Rules!----------------------'.yellow
        puts "You need guess secret code. This four-digit number with symbols from 1 to 6".yellow
        puts "You have #{@game.attempts} attempt(s) and #{@game.hint_count} hint(s)".yellow
        puts "If you want get hint write 'hint'".yellow
        puts '---------------------------------------------'.yellow
        return start
      else
        puts 'Goodbie!'
      end
    end

    def start
      puts "Attempt(s): #{@game.attempts} | Hint(s): #{@game.hint_count}"
      return loose if @game.state == false
      return win if @game.state == true

      action = gets.chomp
      if action == 'hint'
        puts @game.hint
        return start
      end
      unless @game.valid?(action)
        puts 'Invalid data'.red
        return start
      end
      puts coloring(@game.guess(action))
      start
    end

    def win
      puts 'You win!'.green
      puts 'Do you want save result? (Y/N)'
      return puts 'Goodbie!' unless confirm?
      puts 'Write your name'
      @game.save(@path, gets.chomp)
      again?
    end

    def loose
      puts 'You loose!'.red
      again?
    end

    def again?
      puts 'Do you want start again? (Y/N)'
      if confirm?
        Console.new(true)
      else
        puts '-----------Scores----------'.yellow
        puts @game.scores
        puts '---------------------------'.yellow
      end
    end

    def confirm?(action = gets.chomp)
      return true if action == 'Y'
      false
    end

    def coloring(string)
      color_s = ''
      string.chars { |w| color_s += w == '+' ? '+'.green : '-'.red }
      color_s
    end

    def load(path)
      YAML.load(File.open(path)) if File.exist?(path)
    end
  end
end
