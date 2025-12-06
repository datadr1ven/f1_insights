query f1_driver_meeting_performance verb=GET {
  input {
    // The meeting key bound from URL path
    text meeting_key
  
    // Fan preferences
    text fanPrefs?=balanced
  }

  stack {
    var $fanPrefs {
      value = $input.fanPrefs
    }
  
    api.request {
      url = "https://api.openf1.org/v1/laps"
      method = "GET"
      params = {}
        |set:"meeting_key":$input.meeting_key
    } as $laps_response
  
    conditional {
      if ($laps_response.response.status != 200) {
        var $laps {
          value = []
        }
      }
    
      else {
        var $laps {
          value = $laps_response.response.result
        }
      }
    }
  
    api.request {
      url = "https://api.openf1.org/v1/position"
      method = "GET"
      params = {}
        |set:"meeting_key":$input.meeting_key
    } as $positions_response
  
    conditional {
      if ($positions_response.response.status != 200) {
        var $positions {
          value = null
        }
      }
    
      else {
        var $positions {
          value = $positions_response.response.result
        }
      }
    }
  
    var $raw {
      value = {laps: $laps, positions: $positions}
    }
  }

  response = $raw
}