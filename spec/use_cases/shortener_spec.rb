require "rails_helper"

describe Shortener do
  before do
    @statement = create(:statement)
  end

  xit "should shorten an url using Google's Shortener" do
    s = described_class.new(object: @statement, full_url: "http://www.agreelist.org")
    s.clean_cache
    allow(Google::UrlShortener).to receive(:shorten!).and_return("http://short.com")
    expect(s.get).to eq "http://short.com"
  end

  xit "should returned the cached shortened url from redis" do
    # First we store it on redis:
    s = described_class.new(object: @statement, full_url: "http://www.agreelist.org")
    s.clean_cache
    allow(Google::UrlShortener).to receive(:shorten!).and_return("http://short.com")
    expect(s.get).to eq "http://short.com"

    # Now we get it from redis:
    s = described_class.new(object: @statement, full_url: "http://www.agreelist.org")
    expect(s.get).to eq "http://short.com"
  end
end
