require 'rspec'
require 'verona'

RSpec.describe Verona::Configuration do
  subject { described_class.new }

  describe '#use_rails_logger?' do
    it { expect(subject.use_rails_logger?).to be false }
    it { expect(subject.tap { |s| s.use_rails_logger = true }.use_rails_logger?).to be true }
  end
end
