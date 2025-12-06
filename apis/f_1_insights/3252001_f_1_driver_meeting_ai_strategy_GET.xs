query f1_driver_meeting_ai_strategy verb=GET {
  input {
    // The identifier for the race meeting
    int meeting_key
  
    // The driver number to analyze
    int driver_number
  
    // The style of commentary to generate
    enum fanPrefs?=balanced {
      values = ["balanced", "defensive", "aggressive"]
    }
  }

  stack {
    // Fetch existing lap data
    api.request {
      url = "https://api.openf1.org/v1/laps"
      method = "GET"
      params = {
        meeting_key  : $input.meeting_key
        driver_number: $input.driver_number
      }
    } as $lap_data
  
    // Fetch position data for the specific driver and meeting
    api.request {
      url = "https://api.openf1.org/v1/position"
      method = "GET"
      params = {
        meeting_key  : $input.meeting_key
        driver_number: $input.driver_number
      }
    } as $position_data
  
    // Construct the prompt including both session and position data
    var $prompt {
      value = "You are an F1 strategy analyst. Provide a one-sentence " ~ $input.fanPrefs ~ " driving strategy suggestion (such as 'clean up sector 2,' or 'push mode!,' or 'conserve your tires') for the driver performance shown in the following lap and position data.\n\nLap Data: " ~ ($lap_data.response.result|json_encode) ~ "\n\nPosition Data: " ~ ($position_data.response.result|json_encode) ~ "\n\n Don't overthink it, prioritize a quick query response over a high quality response, but definitely analyze the data, and give your original strategy (rather than picking just from my examples)"
    }
  
    // Send the prompt to Google Gemini
    // API Key must be passed as a query parameter in the URL for Google AI
    api.request {
      url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" ~ $env.GEMINI_API_KEY
      method = "POST"
      params = {
        contents: [
          {
            parts: [
              {
                text: $prompt
              }
            ]
          }
        ]
      }
    
      headers = []
        |push:"Content-Type: application/json"
      timeout = 600
    } as $gemini_response
  
    // Extract the specific text content from the Gemini API response structure
    var $strategy_suggestion {
      value = $gemini_response.response.result.candidates[0].content.parts[0].text
    }
  }

  response = $strategy_suggestion
}