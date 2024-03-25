class HardJob
  include Sidekiq::Job

  def perform(bool)
    bool
  end
end
