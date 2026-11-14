-- Renders GitHub alerts (> [!NOTE], > [!IMPORTANT], ...) as styled boxes
-- for pandoc versions without the "alerts" extension.
function BlockQuote(el)
  local first = el.content[1]
  if first and first.t == "Para" and first.content[1] and first.content[1].t == "Str" then
    local kind = first.content[1].text:match("^%[!(%u+)%]$")
    if kind then
      table.remove(first.content, 1)
      while first.content[1] and (first.content[1].t == "SoftBreak" or first.content[1].t == "Space") do
        table.remove(first.content, 1)
      end
      return pandoc.Div(el.content, pandoc.Attr("", {"alert", "alert-" .. kind:lower()}))
    end
  end
end
