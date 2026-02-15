function DefaultSettings() as Object
  return {
    slideSeconds: 60
    metaStartSec: 10
    metaEndSec:   10
    country:      "us"
    units:        "f"      ' "f" or "c"
    zipOverride:  ""       ' optional
    clock24h:     false
  }
end function

function ValOrDefault(v as Dynamic, d as String) as String
  if v = invalid or v = "" then return d
  return v
end function

function iif(cond as Boolean, a as Dynamic, b as Dynamic) as Dynamic
  if cond then return a else return b
end function

' Clock formatting:
' 12h mode: never show leading zero on hour.
' examples: 1:05 am, 9:41 am, 10:03 am, 12:00 pm
function FormatClock(dt as Object, use24h as Boolean) as String
  h = dt.GetHours()      ' 0-23
  m = dt.GetMinutes()    ' 0-59

  mm = m.ToStr()
  if m < 10 then mm = "0" + mm

  if use24h
    hh = h.ToStr()
    if h < 10 then hh = "0" + hh
    return hh + ":" + mm
  end if

  ampm = "am"
  hour12 = h

  if h = 0
    hour12 = 12
    ampm = "am"
  else if h < 12
    hour12 = h
    ampm = "am"
  else if h = 12
    hour12 = 12
    ampm = "pm"
  else
    hour12 = h - 12
    ampm = "pm"
  end if

  return hour12.ToStr() + ":" + mm + " " + ampm
end function

function WeatherIconForCode(code as Integer) as String
  if code = 0 then return "pkg:/images/wx/clear.png"
  if code = 1 or code = 2 then return "pkg:/images/wx/partly.png"
  if code = 3 then return "pkg:/images/wx/cloudy.png"
  if code = 45 or code = 48 then return "pkg:/images/wx/fog.png"

  if code = 51 or code = 53 or code = 55 then return "pkg:/images/wx/drizzle.png"
  if code = 56 or code = 57 then return "pkg:/images/wx/drizzle.png"

  if code = 61 or code = 63 or code = 65 then return "pkg:/images/wx/rain.png"
  if code = 66 or code = 67 then return "pkg:/images/wx/rain.png"

  if code = 71 or code = 73 or code = 75 or code = 77 then return "pkg:/images/wx/snow.png"

  if code = 80 or code = 81 or code = 82 then return "pkg:/images/wx/showers.png"

  if code = 95 or code = 96 or code = 99 then return "pkg:/images/wx/storm.png"

  return "pkg:/images/wx/unknown.png"
end function
