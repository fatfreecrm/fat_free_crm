require 'spec_helper'

RSpec.describe WikidataJob, type: :job do
  let(:account) { create(:account, wikidata_id: 'Q42') }
  let(:service) { instance_double(WikidataService) }

  it 'calls WikidataService' do
    expect(WikidataService).to receive(:new).with(account).and_return(service)
    expect(service).to receive(:call)
    WikidataJob.perform_now(account)
  end
end
