require 'spec_helper'

describe Codeguessing::Game do
  let(:game) { Codeguessing::Game.new }
  MAX_ATTEMPTS = Codeguessing::Game::MAX_ATTEMPTS

  describe '#start' do
    it 'saves secret code' do
      expect(game.secret_code).not_to be_empty
    end
    it 'saves 4 numbers secret code' do
      expect(game.secret_code.size).to eq(4)
    end
    it 'saves secret code with numbers from 1 to 6' do
      expect(game.secret_code).to match(/[1-6]+/)
    end
  end

  describe '#guess' do
    before { game.secret_code = '1234' }
    it 'when win' do
      game.guess('1234')
      expect(game.win?).to eq(true)
    end
    it 'when loose' do
      MAX_ATTEMPTS.times { game.guess('2222') }
      expect(game.win?).to eq(false)
    end
  end

  def self.check_situations(situations, answer)
    situations.each do |situation|
      it "Code: #{situation[0]} | Guess: #{situation[1]}" do
        game.secret_code = situation[0]
        expect(game.get_mark(situation[1])).to eq(answer)
      end
    end
  end

  describe '#get_mark' do
    context 'Empty' do
      situations = [ ['1234', '5555'], ['1111', '2222'] ]
      check_situations(situations, '')
    end
    context '-' do
      situations = [ ['1234', '5155'], ['3111', '1222'] ]
      check_situations(situations, '-')
    end
    context '+' do
      situations = [ ['5554', '1234'], ['1112', '2222'] ]
      check_situations(situations, '+')
    end
    context '--' do
      situations = [ ['2332', '3113'], ['1221', '2332'], ['2424', '3232'] ]
      check_situations(situations, '--')
    end
    context '+-' do
      situations = [ ['1234', '3255'], ['1132', '4143'] ]
      check_situations(situations, '+-')
    end
    context '++' do
      situations = [ ['4562', '5522'], ['3223', '4224'], ['2324', '4524'] ]
      check_situations(situations, '++')
    end
    context '---' do
      situations = [ ['1234', '4325'], ['2323', '3234'], ['1323', '3131'], ['3131', '1323'] ]
      check_situations(situations, '---')
    end
    context '+--' do
      situations = [ ['1234', '2124'], ['1234', '2124'], ['2331', '3233'], ['4131','2341'] ]
      check_situations(situations, '+--')
    end
    context '++-' do
      situations = [ ['1234', '1263'], ['2632', '2352'], ['5231','2331'] ]
      check_situations(situations, '++-')
    end
    context '+++' do
      situations = [ ['1262', '1261'], ['3323', '3363'] ]
      check_situations(situations, '+++')
    end
    context '----' do
      situations = [ ['1234', '4321'], ['5225', '2552'], ['5533','3355'] ]
      check_situations(situations, '----')
    end
    context '+---' do
      situations = [ ['1234', '3241'], ['3243', '3324'] ]
      check_situations(situations, '+---')
    end
    context '++--' do
      situations = [ ['2525', '2552'], ['2525', '2552'], ['2422', '2242'] ]
      check_situations(situations, '++--')
    end
    it '++++' do
      game.secret_code = '1234'
      expect(game.get_mark('1234')).to eq('++++')
    end
  end

  context '#valid?' do
    it 'when invalid' do
      expect(game.valid?('123')).to eq(false)
    end
    it 'when valid' do
      expect(game.valid?('1234')).to eq(true)
    end
  end

  describe '#attempt' do
    it 'attempt limit' do
      expect(game.attempts).to eq(MAX_ATTEMPTS)
    end
    it 'attempt balance' do
      2.times { game.guess('1235') }
      expect(game.attempts).to eq(MAX_ATTEMPTS - 2)
    end
  end

  describe '#hint' do
    it 'use hint' do
      hint = game.hint
      hint.each_char.with_index do |char, index|
        expect(game.secret_code[index]).to eq(char) if char != '*'
      end
    end
    it 'when hint not available' do
      3.times { game.hint }
      expect(game.hint).to eq('')
    end
  end
end
