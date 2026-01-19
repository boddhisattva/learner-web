# frozen_string_literal: true

module ScrollHelpers
  # Turbo lazy loading relies on IntersectionObserver which is unreliable in headless Chrome.
  # This helper scrolls repeatedly until the expected content appears.
  def scroll_until_content_appears(content, max_attempts: 2)
    max_attempts.times do
      return if page.has_content?(content)

      page.scroll_to(:bottom)
      page.execute_script(<<~JS)
        const frame = document.querySelector('turbo-frame[loading=lazy]');
        if (frame) { frame.loading = 'eager'; frame.reload(); }
      JS
    end

    expect(page).to have_content(content)
  end
end

RSpec.configure do |config|
  config.include ScrollHelpers, type: :system
end
