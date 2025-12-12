query f1_driver_meeting_strategy verb=GET {
  api_group = "f1_insights"

  input {
    text meeting_key
    text fanPrefs?=balanced
    text driver_number filters=trim
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
        |set:"driver_number":$input.driver_number
    } as $laps_response
  
    api.request {
      url = "https://api.openf1.org/v1/position"
      method = "GET"
      params = {}
        |set:"meeting_key":$input.meeting_key
        |set:"driver_number":$input.driver_number
    } as $positions_response
  
    api.request {
      url = "https://api.openf1.org/v1/weather"
      method = "GET"
      params = {}
        |set:"meeting_key":$input.meeting_key
    } as $weather_response
  
    var $pref {
      value = $fanPrefs|to_lower
    }
  
    var $multipliers {
      value = {aggressive: 1.18, defensive: 0.88, balanced: 1}
    }
  
    var $multiplier {
      value = $multipliers|get:$pref
    }
  
    var $weather {
      value = $weather_response.response.result
    }
  
    var $weather_summary {
      value = {
        rain    : $weather[-1].rainfall > 0
        wind_kph: $weather[-1].wind_speed
        temp_c  : $weather[01].track_temperature
      }
    }
  
    var $weather_mult {
      value = ($weather[0].rain > 0) ? 0.75 : 1.0
    }
  
    conditional {
      if ($multiplier == null) {
        var.update $multiplier {
          value = 1
        }
      }
    }
  
    var $avg_position {
      value = 10
    }
  
    var $latest_position {
      value = $positions_response.response.result[-1]
    }
  
    conditional {
      if (($positions_response.response.result != null) && ($positions_response.response.result.count > 0)) {
        array.map ($positions_response.response.result) {
          by = $this.position
        } as $pos_values
      
        var.update $avg_position {
          value = $pos_values|avg
        }
      }
    }
  
    var $base_score {
      value = (21.0 - $avg_position) / 20.0
    }
  
    var $personalized_score {
      value = $base_score * $multiplier * $weather_mult
    }
  
    var.update $personalized_score {
      value = $personalized_score|min:1|max:0
    }
  
    var $tips_map {
      value = {
        aggressive: ["Go flat-out in DRS zones!", "Send it!", "Risk sector 2."]
        defensive : ["Protect tires.", "Avoid lap 1 chaos.", "Consistency wins."]
        balanced  : ["Smooth is fast.", "Manage gap.", "Stay calm."]
      }
    }
  
    var $tip_list {
      value = $tips_map|get:$pref
    }
  
    conditional {
      if ($tip_list == null) {
        var.update $tip_list {
          value = $tips_map.balanced
        }
      }
    }
  
    var $tip {
      value = ($tip_list|shuffle)|first
    }
  
    var $enrich {
      value = {
        driver_number     : $input.driver_number
        latest_position   : $latest_position.position
        personalized_score: $personalized_score
        tip               : $tip
        weather_summary   : $weather_summary
        applied_preference: $fanPrefs
      }
    }
  
    var $result {
      value = $enrich
    }
  }

  response = $enrich
}


