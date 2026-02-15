sub init()
  m.settings = LoadSettings()

  m.bg     = m.top.findNode("bg")
  m.clock  = m.top.findNode("clock")

  m.weatherGroup = m.top.findNode("weather")
  m.wxIcon = m.top.findNode("wxIcon")
  m.wxTemps = m.top.findNode("wxTemps")

  m.meta   = m.top.findNode("meta")
  m.metaBg = m.top.findNode("metaBg")

  m.tick     = m.top.findNode("tickTimer")
  m.feedTask = m.top.findNode("feedTask")

  m.weatherTimer = m.top.findNode("weatherTimer")
  m.weatherTask  = m.top.findNode("weatherTask")

  m.fadeIn  = m.top.findNode("metaFadeIn")
  m.fadeOut = m.top.findNode("metaFadeOut")

  m.fadeIn.targets  = [ m.meta, m.metaBg ]
  m.fadeOut.targets = [ m.meta, m.metaBg ]

  m.images = []
  m.index  = 0
  m.slideSecond = 0
  m.metaShouldShow = false

  m.slideDuration = m.settings.slideSeconds
  m.metaStartSec  = m.settings.metaStartSec
  m.metaEndSec    = m.settings.metaEndSec

  m.tick.observeField("fire", "onTick")
  m.feedTask.observeField("content", "onFeedLoaded")

  m.weatherTimer.observeField("fire", "refreshWeather")
  m.weatherTask.observeField("result", "onWeather")

  ' Start
  m.feedTask.country = m.settings.country
  m.feedTask.control = "run"

  m.tick.control = "start"

  m.weatherTimer.control = "start"
  refreshWeather()

  updateClock()
end sub

sub onFeedLoaded()
  m.images = m.feedTask.content
  m.index = 0
  m.slideSecond = 0
  showCurrent()

  m.metaShouldShow = false
  updateMetaVisibility(true)
end sub

sub onTick()
  updateClock()

  if m.images.count() = 0 then return

  m.slideSecond = m.slideSecond + 1

  if m.slideSecond >= m.slideDuration
    m.slideSecond = 0
    m.index = (m.index + 1) mod m.images.count()
    showCurrent()
    updateMetaVisibility(true)
  else
    updateMetaVisibility(false)
  end if
end sub

sub showCurrent()
  if m.images.count() = 0 then return
  item = m.images[m.index]

  url = invalid
  if item.fullUrl <> invalid then url = item.fullUrl else url = item.imageUrl
  m.bg.uri = url

  title = item.title : if title = invalid then title = ""
  cr = item.copyright : if cr = invalid then cr = ""

  metaText = ""
  if title <> "" then metaText = title
  if cr <> "" then
    if metaText <> "" then metaText = metaText + chr(10)
    metaText = metaText + cr
  end if
  m.meta.text = metaText
end sub

sub updateMetaVisibility(force as Boolean)
  sec = m.slideSecond

  startWin = (m.metaStartSec > 0) and (sec < m.metaStartSec)
  endWin   = (m.metaEndSec > 0) and (sec >= (m.slideDuration - m.metaEndSec))
  wantsShow = startWin or endWin

  if m.meta.text = invalid or m.meta.text = "" then wantsShow = false

  if force or (wantsShow <> m.metaShouldShow)
    m.metaShouldShow = wantsShow
    if wantsShow
      m.fadeOut.control = "stop"
      m.fadeIn.control = "start"
    else
      m.fadeIn.control = "stop"
      m.fadeOut.control = "start"
    end if
  end if
end sub

sub updateClock()
  dt = CreateObject("roDateTime")
  m.clock.text = FormatClock(dt, m.settings.clock24h)
end sub

sub refreshWeather()
  zip = m.settings.zipOverride
  if zip = invalid then zip = ""

  if zip = ""
    di = CreateObject("roDeviceInfo")
    ' Some models expose a postal code; if not, this will just be blank/invalid
    if di <> invalid and di.GetPostalCode <> invalid
      zip = di.GetPostalCode()
      if zip = invalid then zip = ""
    end if
  end if

  if zip = ""
    m.weatherGroup.visible = false
    return
  end if

  m.weatherTask.zip = zip
  m.weatherTask.units = m.settings.units  ' "f" or "c"
  m.weatherTask.control = "run"
end sub

sub onWeather()
  r = m.weatherTask.result
  if r = invalid or r.ok <> true
    m.weatherGroup.visible = false
    return
  end if

  m.wxIcon.uri = WeatherIconForCode(r.code)

  deg = chr(176)
  u = iif(r.units="c", "C", "F")
  m.wxTemps.text = "H " + CInt(r.hi).ToStr() + deg + "  L " + CInt(r.lo).ToStr() + deg + " " + u

  m.weatherGroup.visible = true
end sub
