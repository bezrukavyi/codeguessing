require 'spec_helper'
require 'yaml'
require 'colorize'

describe Codeguessing::Console do
  let(:game) { Codeguessing::Game.new }
  let(:console) { Codeguessing::Console.new }

  describe '#initialize' do
    it 'create new game' do
      expect(console.game).to be_a(game.class)
    end
  end

  describe '#rules' do
    let(:wellcome) { "Do you know rules? (Y/N)\n" }
    before do
      allow(console).to receive(:gaming)
      stub_const('Codeguessing::Console::RULES', ['rules'])
    end

    it 'when know rules' do
      allow(console).to receive(:gets).and_return('y')
      expect { console.rules }.to output(wellcome).to_stdout
    end
    it 'when dont know rules' do
      allow(console).to receive(:gets).and_return('n')
      message = wellcome + "rules\n"
      expect { console.rules }.to output(message).to_stdout
    end
  end

  context 'when gaming' do
    let(:game_state) { "Attempt(s): #{game.attempts} | Hint(s): #{game.hint_count}\n" }
    before do
      console.game.secret_code = '2222'
    end
    describe '#go' do
      before do
        allow(console).to receive(:again?)
        allow(console).to receive(:rules)
      end

      it 'when win' do
        allow(console).to receive(:save?)
        message = "You win!\n"
        console.game.state = 'win'
        expect { console.go }.to output(game_state + message).to_stdout
      end
      it 'when loose' do
        message = [
          "You loose!\n",
          "Secret code was #{console.game.secret_code}\n"
        ]
        console.game.state = 'loose'
        expect { console.go }.to output(game_state + message.join('')).to_stdout
      end
    end

    describe '#gaming' do
      before { allow(console).to receive(:go) }
      it 'when valid' do
        allow(console).to receive(:gets).and_return('1234')
        game_res = "+\n"
        expect { console.gaming }.to output(game_res).to_stdout
      end
      it 'when not valid' do
        allow(console).to receive(:gets).and_return('123')
        game_res = "Invalid data\n"
        expect { console.gaming }.to output(game_res).to_stdout
      end
      it 'when hint' do
        allow(console).to receive(:gets).and_return('hint')
        expect { console.gaming }.to output(/\d{1}/).to_stdout
      end
    end

    context 'saving process'do
      let(:question) { "Do you want save result? (Y/N)\n" }
      describe '#save?' do
        it 'when save' do
          message = "Write your name\n"
          allow(console).to receive(:gets)
          allow(console).to receive(:confirm?).and_return(true)
          allow(console).to receive(:save!)
          expect { console.send(:save?) }.to output(question + message).to_stdout
        end
        it 'when not save' do
          message = "Goodbie!\n"
          allow(console).to receive(:confirm?).and_return(false)
          expect { console.send(:save?) }.to output(question + message).to_stdout
        end
      end
      describe '#save!' do
        let(:name) { 'TestRspec' }
        after do
          scores = YAML.load_file(console.path)
          scores.delete_if { |h| h[:name] == name }
          File.open(console.path, 'w') { |f| YAML.dump(scores, f) }
        end
        it 'when save' do
          console.game.state = 'win'
          console.send(:save!, name)
          expect(console.scores).to include(console.game.cur_score(name))
        end
        it 'when not save' do
          message = "You cant save game\n"
          expect { console.send(:save!) }.to output(message).to_stdout
        end
      end
    end

    describe '#again?' do
      before { allow(console).to receive(:go).and_return(console.game) }
      it 'when again' do
        allow(console).to receive(:confirm?).and_return(true)
        expect(console.send(:again?)).to be_a(console.game.class)
      end
      it 'when not again' do
        allow(console).to receive(:confirm?).and_return(false)
        message = [
          "Do you want start again? (Y/N)\n",
          "-----------Scores----------\n",
          "#{console.scores}\n",
          "---------------------------\n"
        ]
        expect { console.send(:again?) }.to output(message.join('')).to_stdout
      end
    end

  end
end
