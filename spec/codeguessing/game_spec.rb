require 'spec_helper'

describe Codeguessing::Game do
  let(:game) { Codeguessing::Game.new }

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
    context 'answer' do
      it '-' do
        expect(game.guess('5155')).to eq('-')
      end
      it '+' do
        expect(game.guess('1555')).to eq('+')
      end
      it '--' do
        expect(game.guess('2155')).to eq('--')
      end
      it '+-' do
        expect(game.guess('4444')).to eq('+-')
      end
      it '++' do
        game.secret_code = '6552'
        expect(game.guess('5555')).to eq('++')
      end
      it '++-' do
        expect(game.guess('1263')).to eq('++-')
      end
      it '+--' do
        expect(game.guess('1623')).to eq('+--')
      end
      it '----' do
        expect(game.guess('3451')).to eq('---')
      end
      it '++++' do
        expect(game.guess('1234')).to eq('++++')
      end
      it 'empty' do
        expect(game.guess('5555')).to eq('')
      end
    end
  end

  context '#valid?' do
    it 'when invalid' do
      expect(game.valid?('dfsdf')).to eq(false)
    end
    it 'when valid' do
      expect(game.valid?('1234')).to eq(true)
    end
  end

  describe '#attempt' do
    it 'attempt limit' do
      expect(game.attempts).to eq(Codeguessing::Game::MAX_ATTEMPTS)
    end
    it 'attempt balance' do
      2.times { game.guess('1235') }
      expect(game.attempts).to eq(Codeguessing::Game::MAX_ATTEMPTS - 2)
    end
    it 'when attempt ended' do
      11.times { game.guess('8765') }
      expect(game.state).to eq(game.loose)
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

# let(:path) { File.absolute_path('lib/codeguessing/scores.yml') }
# let(:scores) { YAML.load(File.open(path)) }

# describe '#save' do
#   it 'when save with loose' do
#     game.loose
#     expect(game.save(path)).to equal(false)
#   end
#   it 'when save with not ended game' do
#     game.guess('1235')
#     expect(game.save(path)).to equal(false)
#   end
#   it 'when save available' do
#     game.win
#     game.save(path, 'Yaroslav')
#     expect(game.scores).to eq(scores)
#   end
# end
