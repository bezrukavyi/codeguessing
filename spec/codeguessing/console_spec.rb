require 'spec_helper'
require 'yaml'
require 'colorize'

describe Codeguessing::Console do
  subject { Codeguessing::Console.new }
  let(:game) { subject.game }
  MESSAGE = Codeguessing::Console::MESSAGE

  describe '#rules' do
    let(:wellcome) { MESSAGE['rules?'] + "\n" }
    before do
      allow(subject).to receive(:gaming)
    end

    it 'when know rules' do
      allow(subject).to receive(:gets).and_return('y')
      expect { subject.rules }.to output(wellcome).to_stdout
    end

    it 'when dont know rules' do
      allow(subject).to receive(:gets).and_return('n')
      message = wellcome + MESSAGE['rules'].join("\n") + "\n"
      expect { subject.rules }.to output(message).to_stdout
    end
  end

  context 'when gaming' do
    let(:game_status) { "Attempt(s): #{game.attempts} | Hint(s): #{game.hint_count}\n" }
    before do
      game.secret_code = '2222'
    end

    describe '#go' do
      before do
        allow(subject).to receive(:again)
        allow(subject).to receive(:rules)
      end

      it 'when win' do
        allow(subject).to receive(:save?)
        message = MESSAGE['win'] + "\n"
        game.state = 'win'
        expect { subject.go }.to output(game_status + message).to_stdout
      end

      it 'when loose' do
        message = [
          "#{MESSAGE['loose']}\n",
          "#{MESSAGE['loose_code']} #{game.secret_code}\n"
        ]
        game.state = 'loose'
        message = game_status + message.join('')
        expect { subject.go }.to output(message).to_stdout
      end
    end

    describe '#gaming' do
      before { allow(subject).to receive(:go) }

      it 'when valid' do
        allow(subject).to receive(:gets).and_return('1234')
        message = "+\n"
        expect { subject.gaming }.to output(message).to_stdout
      end

      it 'when not valid' do
        allow(subject).to receive(:gets).and_return('123')
        message = MESSAGE['invalid_data'] + "\n"
        expect { subject.gaming }.to output(message).to_stdout
      end

      it 'when hint' do
        allow(subject).to receive(:gets).and_return('hint')
        expect { subject.gaming }.to output(/\d{1}/).to_stdout
      end
    end

    context 'saving process'do
      let(:question) { MESSAGE['save?'] + "\n" }

      describe '#save?' do
        it 'when save' do
          allow(subject).to receive(:gets)
          allow(subject).to receive(:save)
          allow(subject).to receive(:confirm?).and_return(true)
          message = MESSAGE['set_name'] + "\n"
          expect { subject.send(:save?) }.to output(question + message).to_stdout
        end

        it 'when not save' do
          allow(subject).to receive(:confirm?).and_return(false)
          message = MESSAGE['not_saved'] + "\n"
          expect { subject.send(:save?) }.to output(question + message).to_stdout
        end
      end

      describe '#save' do
        let(:name) { 'TestRspec' }
        let(:test_path) { File.expand_path('../../fixtures/scores.yml', __FILE__) }
        after do
          File.open(test_path, 'w') { |f| YAML.dump(f) }
        end

        it 'when save' do
          allow(subject).to receive(:path).and_return(test_path)
          game.state = 'win'
          subject.send(:save, 'TestRspec')
          data_scores = YAML.load_file(test_path)
          expect(subject.scores).to eq(data_scores)
        end

        it 'when not save' do
          message = MESSAGE['cant_save'] + "\n"
          expect { subject.send(:save) }.to output(message).to_stdout
        end
      end
    end

    describe '#again?' do
      before { allow(subject).to receive(:go).and_return(game) }

      context 'when again' do
        let(:old_game) { game }
        let(:new_game) { subject.send(:again) }
        before { allow(subject).to receive(:confirm?).and_return(true) }
        it 'must be kind of Game' do
          expect(new_game).to be_a(game.class)
        end
        it 'must be new game' do
          expect(new_game.equal?(old_game)).to be_truthy
        end
      end

      it 'when not again' do
        allow(subject).to receive(:confirm?).and_return(false)
        message = [
          "#{MESSAGE['again?']}\n",
          "#{MESSAGE['scores_line']['start']}\n",
          "#{subject.scores}\n",
          "#{MESSAGE['scores_line']['end']}\n"
        ]
        expect { subject.send(:again) }.to output(message.join('')).to_stdout
      end
    end

  end
end
