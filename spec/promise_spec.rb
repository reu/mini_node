require "spec_helper"

require "mini_node/promise"

RSpec.describe MiniNode::Promise do
  let(:promise) { described_class.new }

  describe "#then" do
    let(:success_block) { spy proc { |result| "Yay: #{result}" } }
    let(:failure_block) { spy proc { |error| "Oh noes: #{error}" } }

    subject { promise.then(success_block, failure_block) }

    it { is_expected.to be_a MiniNode::Promise }
    it { is_expected.to_not eq promise }

    context "when the promise is resolved" do
      before { promise.resolve("Sahsa Grey") }

      it "calls the then block" do
        expect(success_block).to have_received(:call).with("Sasha Grey")
      end
    end
  end
end
