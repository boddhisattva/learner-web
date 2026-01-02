# frozen_string_literal: true

RSpec.configure do |config|
  # Prosopite configuration - N+1 query detection
  config.before do
    Prosopite.scan
  end

  config.after do
    Prosopite.finish
  end
end
