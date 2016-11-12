require 'spec_helper'
require 'yaml'
require 'colorize'

describe Codeguessing::Console do
  let(:console) { Codeguessing::Console.new }
  let(:game) { console.game }
  MESSAGE = Codeguessing::Console::MESSAGE

  describe '#rules' do
    let(:wellcome) { MESSAGE[:rules?] + "\n" }
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
      game.secret_code = '2222'
    end
    describe '#go' do
      before do
        allow(console).to receive(:again?)
        allow(console).to receive(:rules)
      end

      it 'when win' do
        allow(console).to receive(:save?)
        message = MESSAGE[:win] + "\n"
        game.state = 'win'
        expect { console.go }.to output(game_state + message).to_stdout
      end
      it 'when loose' do
        message = [
          "#{MESSAGE[:loose]}\n",
          "#{MESSAGE[:loose_code]} #{game.secret_code}\n"
        ]
        game.state = 'loose'
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
        game_res = MESSAGE[:invalid_data] + "\n"
        expect { console.gaming }.to output(game_res).to_stdout
      end
      it 'when hint' do
        allow(console).to receive(:gets).and_return('hint')
        expect { console.gaming }.to output(/\d{1}/).to_stdout
      end
    end

    context 'saving process'do
      let(:question) { MESSAGE[:save?] + "\n" }
      describe '#save?' do
        it 'when save' do
          message = MESSAGE[:set_name] + "\n"
          allow(console).to receive(:gets)
          allow(console).to receive(:confirm?).and_return(true)
          allow(console).to receive(:save!)
          expect { console.send(:save?) }.to output(question + message).to_stdout
        end
        it 'when not save' do
          message = MESSAGE[:not_save] + "\n"
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
          game.state = 'win'
          console.send(:save!, name)
          expect(console.scores).to include(game.cur_score(name))
        end
        it 'when not save' do
          message = MESSAGE[:cant_save] + "\n"
          expect { console.send(:save!) }.to output(message).to_stdout
        end
      end
    end

    describe '#again?' do
      before { allow(console).to receive(:go).and_return(game) }
      it 'when again' do
        allow(console).to receive(:confirm?).and_return(true)
        expect(console.send(:again?)).to be_a(game.class)
      end
      it 'when not again' do
        allow(console).to receive(:confirm?).and_return(false)
        message = [
          "#{MESSAGE[:again?]}\n",
          "#{MESSAGE[:scores_line][:start]}\n",
          "#{console.scores}\n",
          "#{MESSAGE[:scores_line][:end]}\n"
        ]
        expect { console.send(:again?) }.to output(message.join('')).to_stdout
      end
    end

  end
end
