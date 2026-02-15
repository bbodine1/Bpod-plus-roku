sub init()
  m.top.functionName = "getFeed"
end sub

function getFeed() as Object
  country = m.top.country
  if country = invalid or country = "" then country = "us"

  ' v1: last 5 images only
  url = "https://peapix.com/bing/feed?country=" + country + "&n=5"

  xfer = CreateObject("roUrlTransfer")
  xfer.SetUrl(url)

  rsp = xfer.GetToString()
  if rsp = invalid or rsp = "" then return []

  json = ParseJson(rsp)
  if json = invalid then return []

  out = []
  for each item in json
    out.push({
      title: item.title
      fullUrl: item.fullUrl
      imageUrl: item.imageUrl
      copyright: item.copyright
      pageUrl: item.pageUrl
    })
  end for

  m.top.content = out
  return out
end function
