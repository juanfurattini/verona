require 'rspec'
require 'core_extensions'

RSpec.describe CoreExtensions::Hash::KeyConversions do
  describe '#stringify_keys!' do
    context 'hash with symbolized keys in the root node' do
      let!(:hash) { { a: 1, b: 2, 'c' => 3 } }
      it { expect(hash.stringify_keys!).to eq('a' => 1, 'b' => 2, 'c' => 3) }
    end

    context 'hash with symbolized keys inside of an array' do
      let!(:hash) { { a: 1, b: 2, c: [x: { y: 1, z: 2 }] } }
      it { expect(hash.stringify_keys!).to eq('a' => 1, 'b' => 2, 'c' => ['x' => { 'y' => 1, 'z' => 2 }]) }
    end

    context 'hash with symbolized keys inside of a hash' do
      let!(:hash) { { a: 1, b: 2, c: { x: { y: 1, z: 2 } } } }
      it { expect(hash.stringify_keys!).to eq('a' => 1, 'b' => 2, 'c' => { 'x' => { 'y' => 1, 'z' => 2 } }) }
    end
  end
end