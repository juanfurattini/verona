# frozen_string_literal: true

require 'rspec'
require 'core_extensions'

RSpec.describe CoreExtensions::Object::PresenceCheck do
  describe '#present?' do
    context 'a not nil object' do
      it { expect(Object.new.present?).to be true }
    end

    context 'boolean true' do
      it { expect(true.present?).to be true }
    end

    context 'boolean false' do
      it { expect(false.present?).to be true }
    end

    context 'nil object' do
      it { expect(nil.present?).to be false }
    end
  end

  describe '#not_present?' do
    context 'a not nil object' do
      it { expect(Object.new.not_present?).to be false }
    end

    context 'boolean true' do
      it { expect(true.not_present?).to be false }
    end

    context 'boolean false' do
      it { expect(false.not_present?).to be false }
    end

    context 'nil object' do
      it { expect(nil.not_present?).to be true }
    end
  end
end
