describe("Color conversion functions", function()
	local lib = require("spec/_Setup");
	local getColor = lib.GetColor;
	local err_threshold = 0.01;

	-- samples taken from https://color.adobe.com/create/color-wheel/
	-- "HSB" equals "HSV" here
	Testsamples = {
		{ -- color
			CMYK = {0, 66, 32, 61},
			RGB = {100, 34, 69},
			LAB = {25, 33, -6},
			HSV = {329, 66, 39}, -- (H: 0 ... 359)
		}
	}

	describe("for HSV", function()
		it("convert from RGB and back within margin of error", function()
			assert.are.near({getColor("TEAL")}, {lib.HSVtoRGB(lib.RGBtoHSV(getColor("TEAL")))}, 0.01)
			assert.are.near({getColor("RED")}, {lib.HSVtoRGB(lib.RGBtoHSV(getColor("RED")))}, 0.01)
			assert.are.near({.25, .24, .23, 1}, {lib.HSVtoRGB(lib.RGBtoHSV(.25, .24, .23, 1))}, 0.01)
			assert.are.near({.95, .24, .23, 1}, {lib.HSVtoRGB(lib.RGBtoHSV(.95, .24, .23, 1))}, 0.01)
		end)
	end);
end)