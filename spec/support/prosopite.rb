# frozen_string_literal: true

RSpec.configure do |config|
  # Prosopite configuration - N+1 query detection
  config.before do |example|
    Prosopite.scan unless example.metadata[:prosopite] == :skip
  end

  config.after do |example|
    Prosopite.finish unless example.metadata[:prosopite] == :skip
  end
end
