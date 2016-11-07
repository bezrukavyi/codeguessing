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
      return false unless valid?(code)
      hash = {}
      res = ''
      remaine_chars = code
      right_chars = []
      secret_code.each_char.with_index do |char, i|
        case
        when code[i] == char
          res += '+'
          right_chars << char
          remaine_chars[i] = '*'
          hash.delete(char) if right_chars.include?(char)
        when remaine_chars.include?(char)
          hash[char] = '-'
        end
      end
      res += hash.values.join('')
      win if res == '+' * MAX_SIZE
      @answer = res
    end

    def hint
      res = ''
      need_index = rand(0...MAX_SIZE)
      secret_code.each_char.with_index do |char, index|
        if index == need_index
          res += char
        else
          res += '*'
        end
      end
      return '' unless check?(hint_count)
      use_hint
      res
    end

    def cur_game
      hash = {}
      self.instance_variables.each do |k, v|
        new_k = k.to_s.gsub('@','').to_sym
        hash[new_k] = self.instance_variable_get(k)
      end
      hash
    end

    def cur_score(name = 'Anonim')
      hash = cur_game
      hash[:name] = name
      hash[:date] = Time.now.to_i
      hash.delete(:answer)
      hash.delete(:state)
      hash
    end

    def valid?(code)
      return true if code =~ /^[1-6]{#{MAX_SIZE}}$/s
      false
    end

    def check?(varible)
      return false if varible == 0
      true
    end

    def use_attempt
      @attempts -= 1
    end

    def use_hint
      @hint_count -= 1
    end

    def win
      @state = 'true'
    end

    def loose
      @state = 'false'
    end

    def random
      code = ''
      MAX_SIZE.times { code += rand(1..6).to_s }
      code
    end

  end
end
