import { Controller } from "@hotwired/stimulus"
export default class extends Controller {
  static targets = ["input", "suggestions", "flash"]

  connect() {
    this.debounceTimer = null
    this.logDebounceTimer = null
    this.cachedQueries = []
    this.lastTypedQuery = ""
    this.loggedQueries = new Set()
    this.backspaceMemory = null
    this.backspaceTriggered = false

    
    this.MIN_LETTER_COUNT = 8
    this.MIN_WORD_COUNT = 3

    window.addEventListener("beforeunload", this.handleUnload.bind(this))
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
    clearTimeout(this.logDebounceTimer)
    this.cachedQueries = []
    window.removeEventListener("beforeunload", this.handleUnload.bind(this))
  }

  wordCount(str) {
    return str.trim().split(/\s+/).filter(Boolean).length
  }

  onInput(event) {
    const query = this.inputTarget.value.trim()
    clearTimeout(this.debounceTimer)
    clearTimeout(this.logDebounceTimer)

    if (query === "") {
      this.suggestionsTarget.innerHTML = ""
      this.cachedQueries = []
      return
    }

    if (event.inputType === "deleteContentBackward") {
      if (!this.backspaceTriggered) {
        this.backspaceTriggered = true
        this.backspaceMemory = this.lastTypedQuery
      }
    } else {
      if (this.backspaceTriggered) {
        if (
          this.backspaceMemory &&
          (this.backspaceMemory.length >= this.MIN_LETTER_COUNT &&
            this.wordCount(this.backspaceMemory) >= this.MIN_WORD_COUNT)
        ) {
          this.logSearchQuery(this.backspaceMemory)
        }
        this.backspaceTriggered = false
        this.backspaceMemory = null
      }
    }

    this.lastTypedQuery = query

    // Delay logging if query is valid
    if (
      query.length >= this.MIN_LETTER_COUNT &&
      this.wordCount(query) >= this.MIN_WORD_COUNT
    ) {
      this.logDebounceTimer = setTimeout(() => {
        this.logSearchQuery(query)
      }, 5000)
    }

    const cachedResult = this.findCachedResult(query)
    if (cachedResult) {
      this.renderSuggestions(this.filterCachedResults(cachedResult.results, query))
      return
    }

    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query)
    }, 500)
  }

  findCachedResult(currentQuery) {
    let match = null
    for (const { query: cachedQuery, results } of this.cachedQueries) {
      let isMatch = false
      for (let i = 0; i < results.length; i++) {
        if (results[i].toLowerCase().startsWith(currentQuery.toLowerCase())) {
          isMatch = true
          break
        }
      }

      if (isMatch) {
        match = { query: cachedQuery, results }
        break
      }
    }
    return match
  }

  fetchSuggestions(query) {
    // Then fetch suggestions
    fetch(`/search_queries/suggestions?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => {
        this.cachedQueries.push({ query, results: data })

        if (this.cachedQueries.length > 1000) {
          this.cachedQueries.shift()
        }

        this.renderSuggestions(data)
      })
      .catch(error => {
        console.error("Error fetching suggestions:", error)
      })
  }

  renderSuggestions(results) {
    if (results.length === 0) {
      this.suggestionsTarget.innerHTML = `<p class="text-gray-500 mt-2">No results found.</p>`
      return
    }

    this.suggestionsTarget.innerHTML = `
      <h2 class="text-lg font-medium text-gray-700 mb-2">Search Results:</h2>
      <ul class="space-y-1">
        ${results.map(result => `<li class="text-gray-800">${result}</li>`).join("")}
      </ul>
    `
  }

  filterCachedResults(cachedResults, currentQuery) {
    const queryLower = currentQuery.toLowerCase()
    return cachedResults.filter(result =>
      result.toLowerCase().includes(queryLower)
    )
  }

  handleEnter(event) {
    if (event.key === "Enter") {
      const query = this.inputTarget.value.trim()
      if (
        query.length >= this.MIN_LETTER_COUNT ||
        this.wordCount(query) >= this.MIN_WORD_COUNT
      ) {
        this.logSearchQuery(query)
        this.showFlashMessage("Query logged!")
      }
      this.inputTarget.value = ""
      this.suggestionsTarget.innerHTML = ""
    }
  }

  showFlashMessage(message) {
    this.flashTarget.textContent = message;
    this.flashTarget.classList.remove("hidden");

    setTimeout(() => {
      this.flashTarget.classList.add("hidden");
    }, 1000);
  }

  handleUnload() {
    const query = this.lastTypedQuery.trim()
    if (
      query.length < this.MIN_LETTER_COUNT &&
      this.wordCount(query) < this.MIN_WORD_COUNT
    ) return

    if (this.loggedQueries.has(query)) return

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content
    const data = { query, authenticity_token: csrfToken }

    if (navigator.sendBeacon) {
      const blob = new Blob([JSON.stringify(data)], { type: "application/json" })
      navigator.sendBeacon("/search_queries/log", blob)
    }
  }

  logSearchQuery(query) {
    const trimmed = query.trim()
    if (
      trimmed.length < this.MIN_LETTER_COUNT &&
      this.wordCount(trimmed) < this.MIN_WORD_COUNT
    ) return
    if (this.loggedQueries.has(trimmed)) return

    fetch("/search_queries/log", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ query: trimmed })
    }).catch(error => {
      console.error("Error logging query:", error)
    })

    this.loggedQueries.add(trimmed)
  }
}
