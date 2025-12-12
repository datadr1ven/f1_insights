query f1_driver_meeting_performance verb=GET {
  api_group = "f1_insights"

  input {
    // The meeting key bound from URL path
    text meeting_key
  
    text driver_number? filters=trim
  }

  stack {
    api.request {
      url = "https://api.openf1.org/v1/laps"
      method = "GET"
      params = {}
        |set:"meeting_key":$input.meeting_key
        |set:"driver_number":$input.driver_number
    } as $laps_data
  
    api.request {
      url = "https://api.openf1.org/v1/position"
      method = "GET"
      params = {}
        |set:"meeting_key":$input.meeting_key
        |set:"driver_number":$input.driver_number
    } as $positions_data
  
    api.request {
      url = "https://api.openf1.org/v1/weather"
      method = "GET"
      params = {}
        |set:"meeting_key":$input.meeting_key
    } as $weather_data
  
    var $raw {
      value = {
        laps     : $laps_data
        positions: $positions_data
        weather  : $weather_data
      }
    }
  }

  response = $raw
}