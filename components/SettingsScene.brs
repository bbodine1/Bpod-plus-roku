sub init()
  m.list        = m.top.findNode("list")
  m.preview     = m.top.findNode("preview")
  m.previewHint = m.top.findNode("previewHint")
  m.kbd         = m.top.findNode("zipKeyboard")

  m.list.setFocus(true)

  m.s = m.top.settings
  if m.s = invalid then m.s = DefaultSettings()
  normalize()

  m.inPreview = false

  m.kbd.observeField("buttonSelected", "onZipDialogButton")
  render()
end sub

sub normalize()
  if m.s.slideSeconds = invalid then m.s.slideSeconds = 60
  if m.s.metaStartSec = invalid then m.s.metaStartSec = 10
  if m.s.metaEndSec = invalid then m.s.metaEndSec = 10
  if m.s.country = invalid or m.s.country = "" then m.s.country = "us"
  if m.s.units = invalid or (LCase(m.s.units) <> "c" and LCase(m.s.units) <> "f") then m.s.units = "f"
  if m.s.zipOverride = invalid then m.s.zipOverride = ""
  if m.s.clock24h = invalid then m.s.clock24h = false
end sub

sub render()
  items = CreateObject("roSGNode", "ContentNode")

  addItem(items, "Seconds per image", m.s.slideSeconds.ToStr())
  addItem(items, "Meta seconds (start)", m.s.metaStartSec.ToStr())
  addItem(items, "Meta seconds (end)", m.s.metaEndSec.ToStr())
  addItem(items, "Feed country", UCase(m.s.country))
  addItem(items, "Units", iif(LCase(m.s.units)="c", "Celsius", "Fahrenheit"))
  addItem(items, "Location ZIP (optional)", zipDisplay())

  addItem(items, "Preview", "")
  addItem(items, "Reset to defaults", "")

  m.list.content = items
end sub

function zipDisplay() as String
  z = m.s.zipOverride
  if z = invalid or z = "" then return "Auto"
  return z
end function

sub addItem(parent as Object, label as String, value as String)
  n = parent.createChild("ContentNode")
  if value <> "" then
    n.title = label + ": " + value
  else
    n.title = label
  end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if not press then return false

  if m.inPreview
    exitPreview()
    return true
  end if

  idx = m.list.itemFocused

  if key = "left" or key = "right"
    step = iif(key = "right", 1, -1)
    adjust(idx, step)
    render()
    return true
  end if

  if key = "OK"
    if idx = 5
      openZipDialog()
      return true
    else if idx = 6
      enterPreview()
      return true
    else if idx = 7
      m.s = DefaultSettings()
      normalize()
      render()
      return true
    else
      SaveSettings(m.s)
      m.top.close = true
      return true
    end if
  end if

  if key = "back"
    m.top.close = true
    return true
  end if

  return false
end function

sub adjust(idx as Integer, step as Integer)
  if idx = 0
    m.s.slideSeconds = clampInt(m.s.slideSeconds + (step * 5), 10, 600)
  else if idx = 1
    m.s.metaStartSec = clampInt(m.s.metaStartSec + step, 0, 30)
  else if idx = 2
    m.s.metaEndSec = clampInt(m.s.metaEndSec + step, 0, 30)
  else if idx = 3
    countries = ["us","ca","gb","au","de","fr","jp"]
    m.s.country = cycleList(countries, m.s.country, step)
  else if idx = 4
    ' toggle units
    if LCase(m.s.units) = "f" then m.s.units = "c" else m.s.units = "f"
  end if
end sub

sub openZipDialog()
  m.kbd.text = m.s.zipOverride
  m.kbd.visible = true
  m.kbd.setFocus(true)
end sub

sub onZipDialogButton()
  ' buttonSelected is 0-based: 0 = OK, 1 = Cancel
  b = m.kbd.buttonSelected
  if b = 0
    ' Save only digits, allow blank
    m.s.zipOverride = digitsOnly(m.kbd.text)
    render()
  end if

  m.kbd.visible = false
  m.list.setFocus(true)
end sub

function digitsOnly(s as String) as String
  if s = invalid then return ""
  out = ""
  for i = 0 to Len(s) - 1
    ch = Mid(s, i+1, 1)
    if ch >= "0" and ch <= "9" then out = out + ch
  end for
  return out
end function

sub enterPreview()
  m.inPreview = true
  m.list.visible = false
  m.preview.visible = true
  m.previewHint.visible = true

  m.preview.settings = m.s
  m.preview.active = true
end sub

sub exitPreview()
  m.preview.active = false
  m.preview.visible = false
  m.previewHint.visible = false

  m.list.visible = true
  m.list.setFocus(true)
  m.inPreview = false
end sub

function clampInt(v as Integer, minV as Integer, maxV as Integer) as Integer
  if v < minV then return minV
  if v > maxV then return maxV
  return v
end function

function cycleList(list as Object, current as String, step as Integer) as String
  pos = 0
  for i = 0 to list.count() - 1
    if list[i] = LCase(current) then pos = i : exit for
  end for
  pos = pos + step
  if pos < 0 then pos = list.count() - 1
  if pos >= list.count() then pos = 0
  return list[pos]
end function
