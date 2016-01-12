require 'rails_helper'

RSpec.describe GeocoderJob, type: :job do
  include ActiveJob::TestHelper

  subject(:post) { FactoryGirl.create(:post) }
  subject(:job) { described_class.perform_later(post) }

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in default queue' do
    expect(GeocoderJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    perform_enqueued_jobs { job }
    expect(post.address).not_to eq(nil)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

end
