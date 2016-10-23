module Codeguessing
  class Game
    attr_reader :attempts, :hint_count, :state
    attr_accessor :secret_code

    MAX_HINT = 2
    MAX_ATTEMPTS = 5

    def initialize(opt = {})
      @secret_code = opt[:secret_code] || random
      @attempts = opt[:attempts] || MAX_ATTEMPTS
      @hint_count = opt[:hint_count] || MAX_HINT
      @state = opt[:state] || ''
    end

    def guess(code)
      loose unless check?(use_attempt)
      res = ''
      code.each_char.with_index do |char, i|
        if char == secret_code[i]
          res += '+'
        else
          res += '-'
        end
      end
      win if res == '++++'
      res
    end

    def hint
      res = ''
      need_index = rand(0...4)
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

    def cur_score(name = 'Anonim')
      hash = {}
      hash[:name] = name
      self.instance_variables.each do |k, v|
        new_k = k.to_s.gsub('@','').to_sym
        hash[new_k] = self.instance_variable_get(k)
      end
      hash
    end

    def valid?(code)
      return true if code =~ /^[1-6]{4}$/s
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
      @state = true
    end

    def loose
      @state = false
    end

    def random
      code = ''
      4.times { code += rand(1..6).to_s }
      code
    end

  end
end
