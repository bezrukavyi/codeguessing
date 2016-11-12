module Codeguessing
  class Game
    attr_accessor :attempts, :hint_count, :state, :answer, :secret_code

    MAX_HINT = 2
    MAX_ATTEMPTS = 5
    MAX_SIZE = 4

    def initialize
      @secret_code = random
      @attempts = MAX_ATTEMPTS
      @hint_count = MAX_HINT
      @state = ''
      @answer = ''
    end

    def guess(code)
      @state = 'loose' unless check?(use_attempt)
      @state = 'win' if code == secret_code
      @answer = get_mark(code)
    end

    def get_mark(code)
      return false unless valid?(code)
      hash = {}
      mark = ''
      secret_code.each_char.with_index do |char, i|
        if code[i] == char
          mark += '+'
          code[i] = '*'
          hash.delete(char)
        elsif code.include?(char)
          hash[char] = '-'
        end
      end
      mark += hash.values.join('')
    end

    def hint
      return '' unless check?(hint_count)
      use_hint
      hint = '*' * MAX_SIZE
      index = rand(0...MAX_SIZE)
      hint[index] = secret_code[index]
      hint
    end

    def valid?(code)
      return true if code =~ /^[1-6]{#{MAX_SIZE}}$/s
      false
    end

    def win?
      case @state
      when 'win' then true
      when 'loose' then false
      end
    end

    def cur_score(name = 'Anonim')
      hash = cur_game
      hash[:name] = name
      hash[:attempts] = MAX_SIZE - attempts
      hash[:hint_count] = MAX_HINT - hint_count
      hash[:date] = Time.now.to_i
      hash
    end

    def cur_game
      attributes = instance_variables.map do |var|
        [var[1..-1].to_sym, instance_variable_get(var)]
      end
      attributes.to_h
    end

    private

    def check?(varible)
      return false if varible <= 0
      true
    end

    def random
      code = ''
      MAX_SIZE.times { code += rand(1..6).to_s }
      code
    end

    def use_attempt
      @attempts -= 1
    end

    def use_hint
      @hint_count -= 1
    end

  end
end
