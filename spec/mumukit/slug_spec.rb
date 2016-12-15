require 'spec_helper'

describe Mumukit::Auth::Slug do

  it { expect(Mumukit::Auth::Slug.new('foo', 'bar').to_s).to eq 'foo/bar' }
  it { expect(Mumukit::Auth::Slug.parse('foo/bar').to_s).to eq 'foo/bar' }
  it { expect(Mumukit::Auth::Slug.join('foo', 'bar').to_s).to eq 'foo/bar' }
  it { expect(Mumukit::Auth::Slug.join('foo').to_s).to eq 'foo/_' }
  it { expect(Mumukit::Auth::Slug.join.to_s).to eq '_/_' }

  it { expect { Mumukit::Auth::Slug.join('foo', 'bar', 'baz') }.to raise_error 'Slugs must have up to two parts' }
  it { expect { Mumukit::Auth::Slug.parse('baz') }.to raise_error 'Invalid slug: baz. It must be in first/second format' }
end