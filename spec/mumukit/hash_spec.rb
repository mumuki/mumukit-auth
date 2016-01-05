require_relative '../spec_helper'

describe Hash do
  describe '#dig' do
    it { expect({}.dig(:foo, :bar)).to eq nil }
    it { expect({foo: {}}.dig(:foo, :bar)).to eq nil }
    it { expect({foo: {bar: 2}}.dig(:foo, :bar)).to eq 2 }
    it { expect({foo: {bar: 2}}.dig(:foo, :baz)).to eq nil }
    it { expect({foo: {bar: 2}}.dig(:goo, :bar)).to eq nil }
    it { expect({foo: {bar: {baz: 5}}}.dig(:foo, :bar, :baz)).to eq 5 }
  end
end