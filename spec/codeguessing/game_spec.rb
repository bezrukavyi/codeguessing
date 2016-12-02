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


  describe 'game process' do
    before { game.secret_code = '1234' }

    describe '#guess' do
      it 'when win' do
        game.guess('1234')
        expect(game.win?).to eq(true)
      end
      it 'when loose' do
        MAX_ATTEMPTS.times { game.guess('8765') }
        expect(game.win?).to eq(false)
      end
    end

    describe '#get_mark' do
      it 'empty' do
        expect(game.get_mark('5555')).to eq('')
      end
      it '-' do
        expect(game.get_mark('5155')).to eq('-')
      end
      it '+' do
        game.secret_code = '2222'
        expect(game.get_mark('1234')).to eq('+')
      end
      it '--' do
        game.secret_code = '5225'
        expect(game.get_mark('2552')).to eq('--')
      end
      it '+-' do
        expect(game.get_mark('3255')).to eq('+-')
      end
      it '++' do
        game.secret_code = '4562'
        expect(game.get_mark('5522')).to eq('++')
      end
      it '---' do
        expect(game.get_mark('3112')).to eq('---')
      end
      it '+--' do
        expect(game.get_mark('2124')).to eq('+--')
      end
      it '++-' do
        expect(game.get_mark('1263')).to eq('++-')
      end
      it '+++' do
        game.secret_code = '1262'
        expect(game.get_mark('1261')).to eq('+++')
      end
      it '----' do
        expect(game.get_mark('4321')).to eq('----')
      end
      it '+---' do
        expect(game.get_mark('3241')).to eq('+---')
      end
      it '++--' do
        game.secret_code = '2525'
        expect(game.get_mark('2552')).to eq('++--')
      end
      it '++++' do
        expect(game.get_mark('1234')).to eq('++++')
      end
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
