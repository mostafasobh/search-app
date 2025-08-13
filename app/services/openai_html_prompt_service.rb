require "openai"

class OpenaiHtmlPromptService
  MODEL = "gpt-4o-mini"

  def initialize(user_prompt:, html_fragment:, url:)
    @user_prompt   = user_prompt
    @html_fragment = html_fragment
    @url           = url
    # @client        = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def call
    prompt = build_prompt(@user_prompt, @html_fragment, @url)

    response = @client.chat(
      parameters: {
        model: MODEL,
        messages: [
          { role: "system", content: system_instructions },
          { role: "user", content: prompt }
        ],
        temperature: 0.7
      }
    )

    # Extract raw content from API response
    raw_content = response.dig("choices", 0, "message", "content")

    # Attempt to parse as JSON
    begin
      p raw_content
      JSON.parse(raw_content)
    rescue JSON::ParserError
      { "replacementVal" => "", "tooltipVal" => "" }
    end
  end

  private

  def build_prompt(user_prompt, html_fragment, url)
    <<~PROMPT
      You are a web content transformation assistant.
      The following HTML fragment is selected from the page: #{url}

      HTML Fragment:
      #{html_fragment}

      User request:
      #{user_prompt}

      Your job:
      1. Modify or generate HTML that fulfills the user request in a way that fits naturally in the context of the provided fragment and web page style.
      2. Return **only** a valid JSON object with two keys:
         - "replacementVal": The full HTML replacement content for the selected fragment.
         - "tooltipVal": A compact but visually consistent HTML snippet for tooltip display. It must contain the exact same text as replacementVal but styled/structured so it fits in a small tooltip box.

      Requirements:
      - The tooltipVal must match replacementVal in **textual content**.
      - Both keys must be HTML fragments without `<html>` or `<body>` tags.
      - Output must be a valid JSON object and nothing else.
    PROMPT
  end

  def system_instructions
    "You are a helpful assistant that outputs only JSON in the requested format."
  end
end
