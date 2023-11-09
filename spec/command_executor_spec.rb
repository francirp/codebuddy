require 'spec_helper'
require_relative '../lib/command_executor'

RSpec.describe CommandExecutor do
  subject(:command_executor) { CommandExecutor.new }

  describe '#execute' do
    let(:command) { 'echo Hello' }

    context 'when user confirms execution' do
      before do
        allow(command_executor).to receive(:gets).and_return("y\n")
      end

      it 'executes the command and returns the output' do
        output = command_executor.execute(command)
        expect(output).to include("Command executed successfully")
        expect(output).to include("Hello")
      end
    end

    context 'when user cancels execution' do
      before do
        allow(command_executor).to receive(:gets).and_return("n\n")
      end

      it 'does not execute the command' do
        expect(command_executor.execute(command)).to eq("Command execution cancelled by user.")
      end
    end
  end
end
