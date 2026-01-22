// Shared timing utilities for Stimulus controllers
// Based on 37signals Hotwire best practices

/**
 * Debounce - Waits until user stops acting before executing
 * Like waiting for someone to finish talking before responding
 *
 * Perfect for: search input, form auto-save, window resize
 *
 * @param {Function} fn - The function to debounce
 * @param {Number} delay - How long to wait in milliseconds (default: 300ms)
 * @returns {Function} - Debounced version of the function
 */
export function debounce(fn, delay = 300) {
  let timeoutId = null
  return function(...args) {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn.apply(this, args), delay)
  }
}

/**
 * Throttle - Executes immediately, then ignores calls for a period
 * Like a bouncer letting one person in, then making others wait
 *
 * Perfect for: scroll events, mouse move, button clicks
 *
 * @param {Function} fn - The function to throttle
 * @param {Number} delay - Minimum time between executions (default: 1000ms)
 * @returns {Function} - Throttled version of the function
 */
export function throttle(fn, delay = 1000) {
  let timeoutId = null
  return function(...args) {
    if (!timeoutId) {
      fn.apply(this, args)
      timeoutId = setTimeout(() => timeoutId = null, delay)
    }
  }
}

/**
 * Wait for the next animation frame
 * Useful after Turbo morphs to ensure DOM is updated
 *
 * @returns {Promise} - Resolves on next frame
 */
export function nextFrame() {
  return new Promise(requestAnimationFrame)
}

/**
 * Wait for a specific event to fire once
 *
 * @param {Element} element - The element to listen on
 * @param {String} eventName - Name of the event
 * @returns {Promise} - Resolves when event fires
 */
export function nextEvent(element, eventName) {
  return new Promise(resolve =>
    element.addEventListener(eventName, resolve, { once: true })
  )
}
