require 'spec_helper'

RSpec.describe WikidataService do
  let(:account) { create(:account, wikidata_id: 'Q42', background_info: nil, website: nil) }
  let(:service) { WikidataService.new(account) }
  let(:sparql_client) { instance_double(SPARQL::Client) }
  let(:result) do
    {
      description: 'Test Description',
      website: 'http://test.com',
      twitter: 'test_twitter',
      linkedin: 'test_linkedin',
      instagram: 'test_instagram',
      mastodon: 'test@mastodon.social',
      facebook: 'test_facebook',
      bluesky: 'test.bsky.social',
      blog: 'http://blog.test.com'
    }
  end

  before do
    allow(SPARQL::Client).to receive(:new).and_return(sparql_client)
    allow(sparql_client).to receive(:query).and_return([result])
  end

  it 'updates account fields from Wikidata' do
    service.call
    account.reload

    expect(account.background_info).to eq('Test Description')
    expect(account.website).to eq('http://test.com')
    expect(account.twitter).to eq('https://twitter.com/test_twitter')
    expect(account.linkedin).to eq('https://www.linkedin.com/company/test_linkedin')
    expect(account.instagram).to eq('https://www.instagram.com/test_instagram')
    expect(account.mastodon).to eq('https://mastodon.social/@test')
    expect(account.facebook).to eq('https://www.facebook.com/test_facebook')
    expect(account.bluesky).to eq('https://bsky.app/profile/test.bsky.social')
    expect(account.blog).to eq('http://blog.test.com')
  end

  it 'does not overwrite existing fields' do
    account.update(background_info: 'Existing Description')
    service.call
    expect(account.reload.background_info).to eq('Existing Description')
  end
end
