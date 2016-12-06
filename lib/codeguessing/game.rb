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
      @state = 'loose' unless natural?(use_attempt)
      if code == secret_code
        @state = 'win'
        return @answer = '+' * MAX_SIZE
      end
      @answer = get_mark(code)
    end

    def get_mark(code)
      raise 'Invalid data' unless valid?(code)
      mark = ''
      secret_codes = secret_code.chars
      codes = code.chars

      secret_codes.each_with_index do |char, index|
        next unless char == codes[index]
        secret_codes[index] = nil
        codes[index] = nil
        mark += '+'
      end

      secret_codes.compact.each_with_index do |char, index|
        next unless code_index = codes.index(char)
        codes[code_index] = nil
        mark += '-'
      end

      mark
    end

    def hint
      return '' unless natural?(hint_count)
      use_hint
      hint = '*' * MAX_SIZE
      index = rand(0...MAX_SIZE)
      hint[index] = secret_code[index]
      hint
    end

    def win?
      case @state
      when 'win' then true
      when 'loose' then false
      end
    end

    def cur_score(name = 'Anonim')
      scores = cur_game
      scores[:name] = name
      scores[:attempts] = MAX_SIZE - attempts
      scores[:hint_count] = MAX_HINT - hint_count
      scores[:date] = Time.now.to_i
      scores
    end

    def cur_game
      attributes = instance_variables.map do |var|
        [var[1..-1].to_sym, instance_variable_get(var)]
      end
      attributes.to_h
    end

    def valid?(code)
      return true if code =~ /^[1-6]{#{MAX_SIZE}}$/s
      false
    end

    private

    def natural?(number)
      number >= 0
    end

    def random
      Array.new(MAX_SIZE) { rand(1..6) }.join
    end

    def use_attempt
      @attempts -= 1
    end

    def use_hint
      @hint_count -= 1
    end

  end
end
