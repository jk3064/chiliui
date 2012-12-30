--//=============================================================================
include("keysym.h.lua")

EditBox = Control:Inherit{
  classname= "editbox",

  defaultWidth = 70,
  defaultHeight = 20,

  padding = {0,0,0,0},

  align    = "left",
  valign   = "center",
  text  = "",
  cursor = 1,
  offset = 0,
}

local this = EditBox
local inherited = this.inherited

--//=============================================================================

function EditBox:New(obj)
  obj = inherited.New(self,obj)
  obj:SetText(obj.text)
  return obj
end

function EditBox:HitTest(x,y)
  return self
end
--//=============================================================================

function EditBox:SetText(newtext)
  if (self.text == newtext) then return end 
  self.text = newtext
  self:UpdateLayout()
  self:Invalidate()
end


function EditBox:UpdateLayout()
  local font = self.font

  if (self.autosize) then
    self._text  = self.text
    local w = font:GetTextWidth(self.text);
    local h, d, numLines = font:GetTextHeight(self.text);

    if (self.autoObeyLineHeight) then
      h = math.ceil(numLines * font:GetLineHeight())
    else
      h = math.ceil(h-d)
    end

    local x = self.x
    local y = self.y

    if self.valign == "center" then
      y = math.round(y + (self.height - h) * 0.5)
    elseif self.valign == "bottom" then
      y = y + self.height - h
    elseif self.valign == "top" then
    else
    end

    if self.align == "left" then
    elseif self.align == "right" then
      x = x + self.width - w
    elseif self.align == "center" then
      x = math.round(x + (self.width - w) * 0.5)
    end

    self:_UpdateConstraints(x,y,w,h)
  else
    self._text = font:WrapText(self.text, self.width, self.height)
  end

end

--//=============================================================================

function EditBox:DrawControl()
  --// gets overriden by the skin/theme
end

function EditBox:MouseDown(x, y, ...)
  local found = false
  for i = 1, #self.text do
	local tmp = string.sub(self.text, 1, i)
	if self.font:GetTextWidth(tmp) > x then
	  self.cursor = i
	  found = true
	  break
	end
  end
  if not found then
    self.cursor = #self.text + 1
  end
  inherited.MouseDown(self, x, y, ...)
  self:Invalidate()
  return self
end

function EditBox:MouseUp(...)
  inherited.MouseUp(self, ...)
  self:Invalidate()
  return self
end

function EditBox:KeyPress(key, mods, isRepeat, label, unicode)
  local cp = self.cursor
  local txt = self.text  
  if key == KEYSYMS.RETURN then
    return false
  elseif key == KEYSYMS.BACKSPACE then
    if #txt > 0 and cp > 1 then
      self.cursor = cp - 1
      self.text = string.sub(txt, 1, cp - 2) .. string.sub(txt, cp, #txt)
    end      
  elseif key == KEYSYMS.DELETE then
    if #txt > 0 and cp <= #txt then
      self.text = string.sub(txt, 1, cp - 1) .. string.sub(txt, cp + 1, #txt)
    end
  elseif key == KEYSYMS.LEFT then
    if cp > 1 then
      self.cursor = cp - 1
    end
  elseif key == KEYSYMS.RIGHT then
    if cp <= #txt then
      self.cursor = cp + 1
    end
  elseif key == KEYSYMS.RIGHT then
    if cp <= #txt then
      self.cursor = cp + 1
    end
  elseif key == KEYSYMS.HOME then
    self.cursor = 1
  elseif key == KEYSYMS.END then
    self.cursor = #txt + 1
  else
    local char = nil
    local success, char = pcall(string.char, unicode)   
	if success then
		success = not char:find("%c")
	end
    if not success then
      char = nil
    end
	if char then
		self.text = string.sub(txt, 1, cp - 1) .. char .. 
		  string.sub(txt, cp, #txt)
		self.cursor = cp + 1
	else
		return false
	end
  end
  self:UpdateLayout()
  self:Invalidate()
  return self
end
--//=============================================================================
