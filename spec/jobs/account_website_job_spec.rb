require 'spec_helper'

RSpec.describe AccountWebsiteJob, type: :job do
  let(:account) { create(:account, website: 'http://example.com', phone: nil, email: nil, fax: nil) }
  let(:html_body) do
    <<-HTML
      <html>
        <body>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Organization",
              "telephone": "123-456-7890",
              "email": "info@example.com",
              "faxNumber": "098-765-4321",
              "geo": {
                "@type": "GeoCoordinates",
                "latitude": "40.7128",
                "longitude": "-74.0060"
              },
              "address": {
                "@type": "PostalAddress",
                "streetAddress": "123 Main St",
                "addressLocality": "New York",
                "addressRegion": "NY",
                "postalCode": "10001",
                "addressCountry": "US"
              }
            }
          </script>
        </body>
      </html>
    HTML
  end

  before do
    @http_double = instance_double(Net::HTTP)
    allow(Net::HTTP).to receive(:new).and_return(@http_double)
    allow(@http_double).to receive(:use_ssl=)
    allow(@http_double).to receive(:open_timeout=)
    allow(@http_double).to receive(:read_timeout=)
    allow(@http_double).to receive(:get).and_return(double(is_a?: true, body: html_body))
    # Net::HTTP.get_response(uri) eventually calls start
    allow(@http_double).to receive(:start).and_yield(@http_double)
    # Mocking request_get because get_response uses it
    allow(@http_double).to receive(:request_get).and_return(double(is_a?: true, body: html_body))
  end

  it 'updates account fields from JSON-LD Organization data' do
    expect {
      AccountWebsiteJob.perform_now(account)
    }.to change { account.reload.phone }.to('123-456-7890')
    .and change { account.email }.to('info@example.com')
    .and change { account.fax }.to('098-765-4321')
    .and change { account.latitude }.to(40.7128)
    .and change { account.longitude }.to(-74.0060)
  end

  it 'updates account billing address from JSON-LD' do
    AccountWebsiteJob.perform_now(account)
    account.reload
    address = account.billing_address
    expect(address.street1).to eq('123 Main St')
    expect(address.city).to eq('New York')
    expect(address.state).to eq('NY')
    expect(address.zipcode).to eq('10001')
    expect(address.country).to eq('US')
  end

  it 'updates account social media fields from JSON-LD sameAs array' do
    html = <<-HTML
      <html>
        <body>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Organization",
              "sameAs": [
                "https://www.facebook.com/example",
                "https://www.instagram.com/example",
                "https://twitter.com/example",
                "https://www.linkedin.com/company/example",
                "https://bsky.app/profile/example.bsky.social",
                "https://mastodon.social/@example"
              ]
            }
          </script>
        </body>
      </html>
    HTML
    allow(@http_double).to receive(:get).and_return(double(is_a?: true, body: html))
    allow(@http_double).to receive(:request_get).and_return(double(is_a?: true, body: html))

    expect {
      AccountWebsiteJob.perform_now(account)
    }.to change { account.reload.facebook }.to('https://www.facebook.com/example')
    .and change { account.instagram }.to('https://www.instagram.com/example')
    .and change { account.twitter }.to('https://twitter.com/example')
    .and change { account.linkedin }.to('https://www.linkedin.com/company/example')
    .and change { account.bluesky }.to('https://bsky.app/profile/example.bsky.social')
    .and change { account.mastodon }.to('https://mastodon.social/@example')
  end

  it 'updates account social media fields from JSON-LD sameAs string' do
    html = <<-HTML
      <html>
        <body>
          <script type="application/ld+json">
            {
              "@context": "https://schema.org",
              "@type": "Organization",
              "sameAs": "https://www.facebook.com/example"
            }
          </script>
        </body>
      </html>
    HTML
    allow(@http_double).to receive(:get).and_return(double(is_a?: true, body: html))
    allow(@http_double).to receive(:request_get).and_return(double(is_a?: true, body: html))

    expect {
      AccountWebsiteJob.perform_now(account)
    }.to change { account.reload.facebook }.to('https://www.facebook.com/example')
  end

  it 'does not overwrite existing fields' do
    account.update(phone: '555-5555')
    expect {
      AccountWebsiteJob.perform_now(account)
    }.not_to change { account.reload.phone }
  end

  describe 'Error handling and safety' do
    it 'handles HTTP timeouts gracefully' do
      allow(@http_double).to receive(:get).and_raise(Net::OpenTimeout)

      expect {
        AccountWebsiteJob.perform_now(account)
      }.not_to raise_error
    end

    it 'rejects internal IP addresses (SSRF mitigation)' do
      account.update(website: 'http://192.168.1.1')
      expect(@http_double).not_to receive(:get)

      AccountWebsiteJob.perform_now(account)
    end

    it 'rejects localhost (SSRF mitigation)' do
      account.update(website: 'http://localhost')
      expect(@http_double).not_to receive(:get)

      AccountWebsiteJob.perform_now(account)
    end
  end
end

RSpec.describe 'Account Callback', type: :model do
  include ActiveJob::TestHelper

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  after do
    ActiveJob::Base.queue_adapter = :solid_queue
  end

  it 'enqueues AccountWebsiteJob when website is changed' do
    account = create(:account, website: nil)
    expect {
      account.update(website: 'http://new-website.com')
    }.to enqueue_job(AccountWebsiteJob).with(account)
  end

  it 'does not enqueue AccountWebsiteJob when website is not changed' do
    account = create(:account, website: 'http://old-website.com')
    expect {
      account.update(name: 'New Name')
    }.not_to enqueue_job(AccountWebsiteJob)
  end
end
