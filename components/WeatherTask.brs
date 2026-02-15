sub init()
  m.top.functionName = "run"
end sub

function run() as Object
  zip = m.top.zip
  if zip = invalid then zip = ""
  zip = stripNonDigits(zip)

  if zip = ""
    m.top.result = { ok: false }
    return m.top.result
  end if

  units = LCase(m.top.units)
  if units <> "c" then units = "f"

  geo = httpGetJson("https://geocoding-api.open-meteo.com/v1/search?name=" + zip + "&count=1")
  if geo = invalid or geo.results = invalid or geo.results.count() = 0
    m.top.result = { ok: false }
    return m.top.result
  end if

  lat = geo.results[0].latitude
  lon = geo.results[0].longitude

  tempUnit = iif(units="c", "celsius", "fahrenheit")
  url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat.ToStr() + "&longitude=" + lon.ToStr() + _
        "&daily=weather_code,temperature_2m_max,temperature_2m_min&temperature_unit=" + tempUnit + "&timezone=auto"

  fc = httpGetJson(url)
  if fc = invalid or fc.daily = invalid
    m.top.result = { ok: false }
    return m.top.result
  end if

  code = fc.daily.weather_code[0]
  hi   = fc.daily.temperature_2m_max[0]
  lo   = fc.daily.temperature_2m_min[0]

  m.top.result = { ok: true, code: code, hi: hi, lo: lo, units: units }
  return m.top.result
end function

function httpGetJson(url as String) as Object
  x = CreateObject("roUrlTransfer")
  x.SetUrl(url)
  rsp = x.GetToString()
  if rsp = invalid or rsp = "" then return invalid
  return ParseJson(rsp)
end function

function stripNonDigits(s as String) as String
  out = ""
  for i = 0 to Len(s) - 1
    ch = Mid(s, i+1, 1)
    if ch >= "0" and ch <= "9" then out = out + ch
  end for
  return out
end function
