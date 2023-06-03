describe("Color conversion functions", function()
	local lib = require("spec/_Setup");
	local getColor = lib.GetColor;
	local error_threshold = 0.0001;

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

	function assert_color_near(expect, actual, err)
		for k,v in pairs(actual) do
			assert.are.near(expect[k], actual[k], err);
		end
	end

	describe("for HSV", function()
		it("convert from RGB and back within margin of error", function()
			local exp = {getColor("TEAL")}; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, error_threshold);
			local exp = {getColor("RED") }; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, error_threshold);
			local exp = {.25, .24, .23, 1}; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, error_threshold);
			local exp = {.95, .24, .23, 1}; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, error_threshold);
		end)
	end);
end)