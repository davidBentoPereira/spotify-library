require 'rails_helper'

# TODO: THIS IS A BASIC TEST TO PROVE SIDEKIQ IS WORKING JUST FINE
# TODO: PLEASE DELETE THIS FILE WHEN OTHER TESTS USING SIDEKIQ WILL BE WRITTEN
RSpec.describe HardJob, type: :job do
  it "runs Sidekiq properly" do
    HardJob.perform_async(true)
    expect(described_class).to have_enqueued_sidekiq_job(true)
  end
end
# TODO: THIS IS A BASIC TEST TO PROVE SIDEKIQ IS WORKING JUST FINE
# TODO: PLEASE DELETE THIS FILE WHEN OTHER TESTS USING SIDEKIQ WILL BE WRITTEN