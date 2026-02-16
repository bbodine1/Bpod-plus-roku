sub RunScreenSaver()
  screen = CreateObject("roSGScreen")
  port   = CreateObject("roMessagePort")
  screen.SetMessagePort(port)

  scene = screen.CreateScene("MainScene")
  screen.Show()

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent"
      if msg.isScreenClosed() then return
    end if
  end while
end sub

' ---------- Settings UI Entry Point ----------
sub RunScreenSaverSettings()
  screen = CreateObject("roSGScreen")
  port   = CreateObject("roMessagePort")
  screen.SetMessagePort(port)

  scene = screen.CreateScene("SettingsScene")
  scene.settings = LoadSettings()

  screen.Show()

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent"
      if msg.isScreenClosed() then exit while
    end if
  end while
end sub

' ---------- Registry-backed settings ----------
function LoadSettings() as Object
  s = CreateObject("roRegistrySection", "bpod+_saver")
  d = DefaultSettings()

  out = {
    slideSeconds: ValOrDefault(s.Read("slideSeconds"), d.slideSeconds.ToStr()).ToInt()
    metaStartSec: ValOrDefault(s.Read("metaStartSec"), d.metaStartSec.ToStr()).ToInt()
    metaEndSec:   ValOrDefault(s.Read("metaEndSec"), d.metaEndSec.ToStr()).ToInt()
    country:      ValOrDefault(s.Read("country"), d.country)
    units:        LCase(ValOrDefault(s.Read("units"), d.units))  ' "f" or "c"
    zipOverride:  ValOrDefault(s.Read("zipOverride"), d.zipOverride)
    clock24h:     (ValOrDefault(s.Read("clock24h"), iif(d.clock24h, "1", "0")) = "1")
  }

  if out.units <> "c" then out.units = "f"
  return out
end function

sub SaveSettings(settings as Object)
  s = CreateObject("roRegistrySection", "bpod+_saver")
  s.Write("slideSeconds", settings.slideSeconds.ToStr())
  s.Write("metaStartSec", settings.metaStartSec.ToStr())
  s.Write("metaEndSec", settings.metaEndSec.ToStr())
  s.Write("country", settings.country)
  s.Write("units", LCase(settings.units))
  s.Write("zipOverride", settings.zipOverride)
  s.Write("clock24h", iif(settings.clock24h, "1", "0"))
  s.Flush()
end sub
