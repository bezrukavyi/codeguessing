module Codeguessing
  class Game
    attr_accessor :attempts, :hint_count, :state, :answer, :secret_code

    MAX_HINT = 2
    MAX_ATTEMPTS = 5
    MAX_SIZE = 4

    def initialize(opt = {})
      @secret_code = opt[:secret_code] || random
      @attempts = opt[:attempts] || MAX_ATTEMPTS
      @hint_count = opt[:hint_count] || MAX_HINT
      @state = opt[:state] || ''
      @answer = opt[:answer] || ''
    end

    def guess(code)
      loose unless check?(use_attempt)
      win if code == secret_code
      @answer = get_mark(code)
    end

    def get_mark(code)
      return false unless valid?(code)
      hash = {}
      res = ''
      secret_code.each_char.with_index do |char, i|
        if code[i] == char
          res += '+'
          code[i] = '_'
          hash.delete(char)
        elsif code.include?(char)
          hash[char] = '-'
        end
      end
      res += hash.values.join('')
    end

    def hint
      return '' unless check?(hint_count)
      use_hint
      hint = '*' * MAX_SIZE
      index = rand(0...MAX_SIZE)
      code_char = secret_code[index]
      hint[index] = code_char
      hint
    end

    def cur_score(name = 'Anonim')
      hash = cur_game
      hash[:name] = name
      hash[:date] = Time.now.to_i
      hash
    end

    def valid?(code)
      return true if code =~ /^[1-6]{#{MAX_SIZE}}$/s
      false
    end

    def use_attempt
      @attempts -= 1
    end

    def use_hint
      @hint_count -= 1
    end

    private

    def win
      @state = 'win'
    end

    def loose
      @state = 'loose'
    end

    def check?(varible)
      return false if varible == 0
      true
    end

    def random
      code = ''
      MAX_SIZE.times { code += rand(1..6).to_s }
      code
    end

    def cur_game
      hash = {}
      self.instance_variables.each do |k, v|
        new_k = k.to_s.gsub('@','').to_sym
        hash[new_k] = self.instance_variable_get(k)
      end
      hash
    end

  end
end
