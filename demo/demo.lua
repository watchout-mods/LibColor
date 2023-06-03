local libColor = require("spec/_Setup");
local toHex = libColor.ToHex;
local toCSS = libColor.ToCSS;
local steps = 30;
print([[<html style='background-color: #333'>
	<head><style>
	body {
		color: white;
		font-family: Tahoma, sans;
	}
	div.col {
		display: block;
		float:left;
		width:20px;height:20px;margin:1px 0 0 1px; padding:0;
	}
	br {
		clear: both;
	}
	</style></head>
]])
print("<body>")

function blenders(colorFrom, colorTo)
	local blender = libColor.CreateColorBlender(colorFrom, colorTo);
	for i = 0, steps do
	print(('	<div class="col" style="background:#%s"></div>'):format(toHex(blender(i / steps))));
	end
	print(("	&nbsp;Linear blending of %s to %s in RGB color-space<br/>"):format(colorFrom, colorTo));

	local blender = libColor.CreateHueBlender(libColor.RGBtoHSV, libColor.HSVtoRGB, colorFrom, colorTo);
	for i = 0, steps do
	print(('	<div class="col" style="background:#%s"></div>'):format(toHex(blender(i / steps))));
	end
	print(("	&nbsp;Linear blending of %s to %s in HSV color-space<br/>"):format(colorFrom, colorTo));

	local blender = libColor.CreateHueBlender(libColor.RGBtoHSL, libColor.HSLtoRGB, colorFrom, colorTo);
	for i = 0, steps do
	print(('	<div class="col" style="background:#%s"></div>'):format(toHex(blender(i / steps))));
	end
	print(("	&nbsp;Linear blending of %s to %s in HSL color-space<br/>"):format(colorFrom, colorTo));
	print(("	<br/>"));
end

blenders("BLACK", "WHITE");
blenders("RED", "BLUE"); -- HSL/HSV icorrect, they should wrap
blenders("BLUE", "GREEN");
blenders("GREEN", "RED");
blenders("DARKPURPLE", "YELLOW"); -- again HSL/HSV should wrap around H
blenders("RED", "TEAL");
blenders("BLUE", "WHITE");
blenders("BLACK", "YELLOW");
blenders("LIGHTBLUE", "DARKGREEN");

print("</body></html>")
