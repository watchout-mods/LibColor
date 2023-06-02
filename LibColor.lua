---
-- LibColor provides a number of functions that operate on colors.
-- With strong type checking, LibColor assures consistent return values and
-- minimal error output.
--
-- Color types
-- -----------
--
-- LibColor supports three variants of color representation in most functions:
--
-- * __Color list__: A list of individual values for each color part (Red,  Green, Blue and
--   optionally Alpha)
-- * __Color name__: A string representing a color name, like "PURPLE". These values are pre-defined
--   in the library. See *Color names* below.
-- * __Color table__: A table representing an *array* of three (for RGB) or four values (for RGBA).
--   The table representation is restricted to the array part for better performance (as opposed to
--   the blizzard variant of defining red, green and blue with string indexes ('r', 'g', 'b', 'a').
--
-- Color names
-- -----------
-- 
-- LibColor supports the basic colors like RED, GREEN and BLUE, and so on. You
-- can find a complete list in the source or by dumping the contents of the
-- table `LibColor.Colors`.
-- 
-- Additionally, LibColor imports colors from `PowerBarColor` as `POWER_<Name>`
-- and from `RAID_CLASS_COLORS` as `CLASS_<Name>`. To prevent possible errors,
-- the colors `POWER_UNKNOWN` and `POWER_` have been added as well.
--
-- Since the table `LibColors.Colors` is accessible from outside the library, it
-- is theoretically possible to extend it. Since I can not prevent it in any way
-- other than preventing access to the table, I will here suggest a naming
-- convention for those:
-- 
--     '_' ADDONNAME '_' COLORNAME
-- 
-- So grid might have it's custom color `BACKGROUND`. You would name it
-- `_GRID_BACKGROUND`. This also means that this library will never declare a
-- color starting with an underscore.
--/
local MAJOR, MINOR = "LibColor-2", 1;
local Lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR);
if not Lib then return; end

local min, max, floor = math.min, math.max, math.floor;

local DefaultColors = {
--  COLOR  = { R, G, B, A},
	RED    = { 1, 0, 0, 1}, GREEN  = { 0, 1, 0, 1}, BLUE   = { 0, 0, 1, 1},
	PURPLE = { 1, 0, 1, 1}, PINK   = { 1,.2,.7, 1}, YELLOW = { 1, 1, 0, 1},
	ORANGE = {.9,.6,.1, 1}, TEAL   = { 0, 1, 1, 1},
	BLACK  = { 0, 0, 0, 1}, GREY   = {.5,.5,.5, 1}, WHITE  = { 1, 1, 1, 1}, 
	GREY10 = {.1,.1,.1, 1}, GREY20 = {.2,.2,.2, 1}, GREY30 = {.3,.3,.3, 1},
	GREY40 = {.4,.4,.4, 1}, GREY50 = {.5,.5,.5, 1}, GREY60 = {.6,.6,.6, 1},
	GREY70 = {.7,.7,.7, 1}, GREY80 = {.8,.8,.8, 1}, GREY90 = {.9,.9,.9, 1},
	DARKGREY   = {.2,.2,.2, 1}, LIGHTGREY  = {.8,.8,.8, 1},
	DARKRED    = {.4, 0, 0, 1}, LIGHTRED   = { 1,.6,.6, 1},
	DARKGREEN  = { 0,.4, 0, 1}, LIGHTGREEN = {.6, 1,.6, 1},
	DARKBLUE   = { 0, 0,.4, 1}, LIGHTBLUE  = {.6,.6, 1, 1},
	DARKPURPLE = {.4, 0,.4, 1},
	HEALTH     = { 0, 1, 0, 1}, POWER_UNKNOWN = {.6,.6,.6, 1}, 
}
DefaultColors.GRAY = DefaultColors.GREY;
DefaultColors.POWER_ = DefaultColors.POWER_UNKNOWN;

do -- mix in colors from PowerBarColor
	for k,v in pairs(PowerBarColor or {}) do
		if type(k) == "string" and v.r then
			DefaultColors["POWER_"..k] = { v.r, v.g, v.b, 1 };
		end
	end
	-- chi is called LIGHT_FORCE ... whatever
	DefaultColors.POWER_CHI = DefaultColors.POWER_LIGHT_FORCE;
	-- Make mana color a bit easier on the eye
	DefaultColors.POWER_MANA = {.1, .2, 1, 1};
end
do -- mix in colors from RAID_CLASS_COLORS
	for k,v in pairs(RAID_CLASS_COLORS or {}) do
		local tbl = {v[r], v[g], v[b], v[a] or 1};
		DefaultColors["CLASS_"..tostring(k)] = tbl;
	end
end

-- mix color constants into the Lib
for k,v in pairs(DefaultColors) do
	Lib[k] = v;
end
Lib.Colors = DefaultColors;

local getColor, blendColor, createColorBlender;
local isColorTable, isColorList, isColorName, isColor, isGray;
local tostringall, strjoin = tostringall, strjoin;

local function liberr(message, ...)
	error(MAJOR .. ": " .. message, ...);
end

local function argerr(f, argnum, expect, got)
	liberr(("Bad argument #%s to %s (%s expected, got '%s')"):format(argnum, f, expect, got));
end

---
-- Returns whether the given table is a valid "Blizzard" color table.
-- 
-- Blizzard color tables are of the form:
--     { r = <0..1>, g = <0..1>, b = <0..1>[, a = <0..1>]}
-- 
-- @return <tt>true</tt> if the given table is a valid Blizzard color table, <tt>false</tt>
--         otherwise.
local function isBlizColorTable(tbl)
	if not tbl or type(tbl)~="table" or not tbl.r or not tbl.g or not tbl.b then
		return false;
	end
	
	return isColorList(tbl.r, tbl.g, tbl.b, tbl.a);
end

---
-- Returns Red, Green, Blue and Alpha values from various input types.
-- 
-- * `r,g,b,a = Lib:GetColor(String [, Alpha])` (See `Lib.IsColorName`)
-- * `r,g,b,a = Lib:GetColor(ColorTable)` (See `Lib.IsColorTable`
-- * `r,g,b,a = Lib:GetColor(Red, Green, Blue[, Alpha])` (See `Lib.IsColorList`)
--
-- Possible parameter variants are:
-- <dl>
--   <dt>COLOR_NAME[, alpha]</dt><dd>A string containing a color name constant for which
--   `Lib.IsColorName` would return `true`. An optional numerical alpha value in the range `0..1`
--   may be added as second parameter.</dd>
--   <dt>Color Table</dt><dd>an array-table of the form `{r, g, b, a}` that would be accepted by
--   `Lib.IsColorTable`</dd>
--   <dt>Color List</dt><dd>a list of three or four real number values `r, g, b[, a]` in the range
--   `0..1` that would be accepted by `Lib.IsColorList`
--   </dd>
-- </dl>
-- @function Lib.GetColor(...)
-- @param ... a <tt>Color</tt> value as defined above.that consists of either:
function Lib.GetColor(c, ...)
	--print(MAJOR, c, ...);
	local input_t = type(c);
	local argc = select('#', ...) + 1;
	local red, green, blue, alpha;
	
	if input_t == "string" then
		local cs = DefaultColors[c];
		if cs and isColorTable(cs) then
			local alpha1 = ...
			red, green, blue, alpha = unpack(cs);
			-- TODO: Typecheck of alpha1
			if alpha1 and alpha1*0 == 0 and alpha1 <= 1 and alpha1 >= 0 then
				alpha = alpha1;
			end
		end
	elseif input_t == "table" then
		if isColorTable(c) then
			red, green, blue, alpha = unpack(c);
		end
	elseif (argc == 4 or argc == 3) and isColorList(c, ...) then
		red, green, blue, alpha = c, ...;
	end
	
	if not red then
		error("Not a color <"..strjoin(", ", tostringall(c, ...))..">");
	end
	return red, green, blue, alpha;
end

---
-- Trims a value to the range <tt>0..1</tt>.
-- 
-- @param value the value to trim
-- @return exactly <tt>value</tt> if the <tt>value</tt> is <tt>nil</tt> or in the range <tt>
--  (0..1)</tt>. Otherwise, if <tt>value &lt; 0</tt>, returns <tt>0</tt> and if <tt>value &gt;
--  1</tt>, returns <tt>1</tt>.
function Lib.TrimValue(value)
	if value then
		if value < 0 then
			return 0;
		elseif value > 1 then 
			return 1;
		end
	end
	return value;
end

---
-- Returns whether the given name represents a valid color.
--
-- No color names containing special characters like accents, umlauts, etc. are planned.
-- 
-- Predefined color names contain only UPPER CASE characters A-Z, the character "_" or numbers (no
-- decimal point, comma, or whatever)
--
-- Use <tt>Lib.GetColorNames()</tt> to get a list of (currently) valid names.
function Lib.IsColorName(name)
	return not not DefaultColors[name or ''];
end

---
-- Returns whether the given values represent a valid color list.
--
-- Alpha is optional and thus may be a number from 0 to 1 or false or nil.
--
-- @return <tt>true</tt> if the given parameters make up a valid color list, otherwise
--  <tt>false</tt>.
function Lib.IsColorList(R, G, B, A)
	if (type(R) ~= "number") or (R*0~=0) or (R < 0) or (R > 1) then return false; end
	if (type(G) ~= "number") or (G*0~=0) or (G < 0) or (G > 1) then return false; end
	if (type(B) ~= "number") or (B*0~=0) or (B < 0) or (B > 1) then return false; end
	A = A or 1;
	if (type(A) ~= "number") or (A*0~=0) or (A < 0) or (A > 1) then return false; end
	return true;
end

---
-- Returns whether the given value/table is a valid color table.
--
-- Color tables contain three or four numerically indexed items for the individual RGB color
-- channels - Red, Green, Blue and Alpha - where individual values must range from 0 to 1 and Alpha
-- is optional and thus may be a number from 0 to 1 or false or nil.
--
-- The first item must be at index 1 and the table must be gapless - that means color red is at
-- index 1, green index 2, blue index 3 and alpha may or may not exist but if it does, it is at
-- index 4.
--
-- @param tbl the argument to test
-- @return <tt>true</tt> if the given parameter is a valid color table, otherwise <tt>false</tt>.
function Lib.IsColorTable(tbl)
	if (not tbl) or (type(tbl) ~= "table") or (#tbl ~= 3 and #tbl ~= 4) then
		return false;
	end
	
	return isColorList(tbl[1], tbl[2], tbl[3], tbl[4]);
end

---
-- Returns whether the given value describes a color in any possible form.
--
-- @param ... any value
-- @return <tt>true</tt> if the given parameters can be interpreted as one of the accepted input
--  color types, <tt>false</tt> otherwise.
function Lib.IsColor(...)
	return isColorList(...) or isColorTable(...) or isColorName(...);
end

---
-- Blends between two colors and returns the blended color.
--
-- @param col_from <tt>Color</tt> starting color
-- @param col_to   <tt>Color</tt> end color
-- @param pos      Number may be any number from 0 to 1. 0 will return exactly the "from" color, 1
--  will return exactly the color "to", numbers in between are blended proportionally.
-- @return <tt>(r, g, b, a)</tt> - an <tt>RGB[A]</tt> color list
function Lib.BlendColor(col_from, col_to, pos)
	local cfr, cfg, cfb, cfa = getColor(col_from);
	local ctr, ctg, ctb, cta = getColor(col_to);
	if not cfr or not ctr then
		error(MAJOR..":blendColor(...) one of arguments <1,2> is not a color.");
	end
	if not pos or type(pos) ~= "number" then
		error(MAJOR..":blendColor(...) argument 3 (pos) must be a number from 0 to 1.");
	end
	if pos < 0 then pos = 0; end;
	if pos > 1 then pos = 1; end;
	return cfr + ((ctr-cfr) * pos), cfg + ((ctg-cfg) * pos),
		   cfb + ((ctb-cfb) * pos), cfa + ((cta-cfa) * pos);
end

---
-- Creates a function that blends between two colors using a linear blending.
--
-- @param col_from <tt>Color</tt> starting color
-- @param col_to   <tt>Color</tt> end color
-- @return <tt>function (r,g,b,a = blender(frac))</tt>
function Lib.CreateColorBlender(col_from, col_to)
	local cfr, cfg, cfb, cfa = getColor(col_from);
	local ctr, ctg, ctb, cta = getColor(col_to);
	local cdr, cdg, cdb, cda = ctr-cfr, ctg-cfg, ctb-cfb, cta-cfa;
	if not cfr or not ctr then
		error(MAJOR..":createColorBlender(...) one of arguments <1,2> is not a color.");
	end
	---
	-- Blends between two colors and returns the blended color.
	--
	-- @param pos Number<0..1> `0` will return exactly the "from" color supplied
	--            to CreateColorBlender(...) and `1` will return exactly the
	--            color "to". Numbers in between are blended proportionally.
	-- @return <tt>(r, g, b, a)</tt> - an <tt>RGB[A]</tt> color list
	local function blend(pos)
		if not pos or type(pos) ~= "number" then
			error(MAJOR.."::ColorBlender(...) argument 1 (pos) must be a number from 0 to 1. But is: "..tostring(pos));
		end
		if pos < 0 then pos = 0; end;
		if pos > 1 then pos = 1; end;
		return cfr + cdr*pos, cfg + cdg*pos, cfb + cdb*pos, cfa + cda*pos;
	end
	return blend;
end

---
-- Desaturates the given color to retain only Luminosity.
--
-- NYT
--
-- @param ... a <tt>Color</tt> value that can be passed to :GetColor(...)
-- @return <tt>(r, g, b, a)</tt> RGB[A] color list
function Lib.Desaturate(...)
	local r,g,b,a = getColor(...);
	local l = (min(r,g,b)+max(r,g,b))/2;
	
	return l, l, l, a;
end

---
-- Naiive function to modify the luminosity of a color using linear blending.
--
-- The function should not be assumed to be anywhere near correct HSL conversion
-- but rather "Quick and dirty".
-- 
-- NYT
--
-- @param value Number<0..1> Where 0 means black and 1 means white.
-- @param ... any <tt>Color</tt> value that can be passed to :GetColor(...)
-- @return <tt>(r, g, b, a)</tt> RGB[A] color list
function Lib.ModifyLuminosity_old(value, ...)
	if type(value) ~= "number" then
		argerr("ModifyLuminosity_old", 1, "number from 0 to 1", tostring(value));
	end
	local r,g,b,a = getColor(...);
	local low, high = min(r,g,b), max(r,g,b);
	local lum = (low+high)/2;
	if value > lum then
		return blendColor({r,g,b,a}, {getColor("WHITE", a)}, (1-value)/(value-lum));
	else
		return blendColor({getColor("BLACK", a)}, {r,g,b,a}, lum/(lum-value));
	end
end

---
-- Function to modify the luminosity of a color using RGB-HSL conversion.
-- 
-- NYT
--
-- @param ... any <tt>Color</tt> value that can be passed to :GetColor(...)
-- @return <tt>(r, g, b, a)</tt> RGB[A] color list
function Lib.GetLuminosity(...)
	local r, g, b, a = getColor(...);
	local hi, lo = max(r, g, b), min(r, g, b);

	return (hi + lo) / 2;
end

---
-- Function to modify the luminosity of a color using RGB-HSL conversion.
-- 
-- NYT
--
-- @param factor Number<0 .. inf.> a factor that is applied to the luminosity value. The result is
--  bounded by 0 .. 1.
-- @param ... any value that can be passed to :GetColor(...)
-- @return r, g, b, a values
function Lib.ModifyLuminosity(factor, ...)
	if type(factor) ~= "number" or factor < 0 then
		argerr("ModifyLuminosity", 1, "positive number or zero", tostring(factor));
	end
	local h,s,l,a = Lib.RGBtoHSL(getColor(...));
	return Lib.HSLtoRGB(h, s, max(1, l * factor), a);
end

---
-- Function to set the luminosity of a color using RGB-HSL conversion.
-- 
-- NYT
--
-- @param value Number<0..1> Where 0 means black and 1 means full hue.
-- @param ... any value that can be passed to :GetColor(...)
-- @return r, g, b, a values
function Lib.SetLuminosity(value, ...)
	if type(value) ~= "number" then
		argerr("SetLuminosity", 1, "number from 0 to 1", tostring(value));
	end
	local h,s,l,a = Lib.RGBtoHSL(getColor(...));
	return Lib.HSLtoRGB(h, s, value, a);
end

---
-- Returns a color that should be reasonably readable as text in front of a
-- background colored with the color supplied as argument.
-- 
-- @param ... any value that can be passed to :GetColor(...)
-- @return r, g, b, a values
function Lib.GetColorForText(...)
	local r,g,b,a = getColor(...);
	local low, high = min(r,g,b), max(r,g,b);
	local lum = (low+high)/2;
	if lum < .6666666 then
		return getColor("WHITE");
	else
		return getColor("DARKGREY");
	end
end


---
-- Converts an RGB color value to HSL.
-- 
-- Conversion formula adapted from http://en.wikipedia.org/wiki/HSL_color_space.
-- Ported from http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--
-- This function was not tested yet!
--
-- @param r <tt>Number<0..1></tt> The red color value
-- @param g <tt>Number<0..1></tt> The green color value
-- @param b <tt>Number<0..1></tt> The blue color value
-- @param a <tt>Number<0..1></tt> The alpha value
-- @return <tt>(h, s, l, a)</tt> The HSL representation
--
function Lib.RGBtoHSL(r, g, b, a)
	local hi, lo = max(r, g, b), min(r, g, b);
	local h, s, l = 0, 0, (hi + lo) / 2;

	if hi ~= lo then -- not greyscale
		local d = hi - lo;
		if l > 0.5 then
			s = d / (2 - hi - lo);
		else
			s = d / (hi + lo);
		end
		
		if hi == r and g < b then   h = (g - b) / d + (6);
		elseif hi == r then         h = (g - b) / d + (0);
		elseif hi == g then         h = (b - r) / d + 2;
		elseif hi == b then         h = (r - g) / d + 4;
		end
		h = h / 6;
	end
	
	return h, s, l, a;
end

---
-- Converts an HSL color value to RGB.
--
-- Conversion formula adapted from http://en.wikipedia.org/wiki/HSL_color_space
-- . And ported from http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--
-- This function was not tested yet!
--
-- @param h <tt>Number<0..1></tt> The hue value
-- @param s <tt>Number<0..1></tt> The saturation value
-- @param l <tt>Number<0..1></tt> The lightness value
-- @param a <tt>Number<0..1></tt> The alpha value
-- @return <tt>(r, g, b, a)</tt> The RGB representation
--
function Lib.HSLtoRGB(h, s, l, a)
	local r, g, b = l, l, l;

	if s ~= 0 then
		local function hue2rgb(p, q, t)
			if t < 0 then t = t + 1;
			elseif t > 1 then t = t - 1; end
			
			if t < 1/6 then return p + (q - p) * 6 * t; end
			if t < 1/2 then return q; end
			if t < 2/3 then return p + (q - p) * (2/3 - t) * 6; end
			return p;
		end

		local p, q;
		if l < .5 then
			q = l * (1 + s);
		else
			q = l + s - l * s;
		end
		p = 2 * l - q;
		r = hue2rgb(p, q, h + 1/3);
		g = hue2rgb(p, q, h);
		b = hue2rgb(p, q, h - 1/3);
	end

	return r, g, b, a;
end

---
-- Converts an RGB color value to HSV. Conversion formula
-- adapted from http://en.wikipedia.org/wiki/HSV_color_space. And ported from
-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--
-- This function was not tested yet!
--
-- @param r <tt>Number<0..1></tt> The red color value
-- @param g <tt>Number<0..1></tt> The green color value
-- @param b <tt>Number<0..1></tt> The blue color value
-- @param a <tt>Number<0..1></tt> The alpha value
-- @return <tt>(h, s, v, a)</tt> The HSV representation
--
function Lib.RGBtoHSV(r, g, b, a)
	local hi, lo = max(r, g, b), min(r, g, b);
	local h, s, v = 0, 0, hi;
	
	if hi ~= lo then
		local d = hi - lo;
		s = d / hi;

		if hi == r and g < b then   h = (g - b) / d + 6;
		elseif hi == r then         h = (g - b) / d + 0;
		elseif hi == g then         h = (b - r) / d + 2;
		else                        h = (r - g) / d + 4; -- hi == b
		end
		h = h / 6;
	end

	return h, s, v, a;
end

---
-- Converts an HSV color value to RGB. Conversion formula
-- adapted from http://en.wikipedia.org/wiki/HSV_color_space. And ported from
-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--
-- This function was not tested yet!
--
-- @param h <tt>Number<0..1></tt> The hue
-- @param s <tt>Number<0..1></tt> The saturation
-- @param v <tt>Number<0..1></tt> The value
-- @param a <tt>Number<0..1></tt> The alpha value
-- @return  r, g, b, a   The RGB representation
--
function Lib.HSVtoRGB(h, s, v, a)
	local r, g, b = 0, 0, 0;

	local i = floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	if i == 0 or i == 6 then return v, t, p, a;
	elseif i == 1 then       return q, v, p, a;
	elseif i == 2 then       return p, v, t, a;
	elseif i == 3 then       return p, q, v, a;
	elseif i == 4 then       return t, p, v, a;
	elseif i == 5 then       return v, p, q, a;
	end

	return r, g, b, a;
end

-- assign the functions to variables local-to-file for better performance
getColor = Lib.GetColor;
blendColor = Lib.BlendColor;
createColorBlender = Lib.CreateColorBlender;

isColor = Lib.IsColor;
isColorList = Lib.IsColorList;
isColorName = Lib.IsColorName;
isColorTable = Lib.IsColorTable;

Lib.IsBlizColorTable = isBlizColorTable;

--[[ ---------------------------------------------------------------------- ]]--
--[[                            EMBEDDING  STUFF                            ]]--
--[[ ---------------------------------------------------------------------- ]]--
do -- Embedding
	Lib.MixinTargets = Lib.MixinTargets or {};
	local mixins = {
		"GetColor", "BlendColor", "CreateColorBlender", "ModifyLuminosity",
		"IsColor", "IsColorTable", "IsBlizColorTable", "IsColorList", "IsColorName",
		"GetColorForText",
		"Colors", -- contains color constants
	};

	function Lib:Embed(target)
		for _,name in pairs(mixins) do
			target[name] = Lib[name];
		end
		self.MixinTargets[target] = true;
	end

	-- re-embed (if old lib was loaded first)
	if oldminor and MINOR > oldminor then
		for target,_ in pairs(Lib.MixinTargets) do
			Lib:Embed(target);
		end
	end
end