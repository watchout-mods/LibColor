describe("Color conversion functions", function()
	local lib = require("spec/_Setup");
	local getColor = lib.GetColor;
	local tolerance = 0.001;

	-- samples taken from https://color.adobe.com/create/color-wheel/
	-- "HSB" equals "HSV" here
	Testsamples = {
		{ -- color
			CMYK = {0, 66, 32, 61, 1},
			RGB = {100, 34, 69, 1},
			LAB = {25, 33, -6, 1},
			HSV = {328, 66, 39, 1}, -- (H: 0..359)
		}
	}

	-- Convert color to internal representation
	for k, value in pairs(Testsamples) do
		do -- Convert RGB
			local r, g, b, a = unpack(value.RGB);
			r = r / 255;
			g = g / 255;
			b = b / 255;
			value.RGB = {r, g, b, a};
		end
		do -- Convert HSV
			local h, s, v, a = unpack(value.HSV);
			h = h / 360;
			s = s / 100;
			v = v / 100;
			value.HSV = {h, s, v, a};
		end
	end

	function assert_color_near(expect, actual, err)
		for k,v in pairs(actual) do
			assert.are.near(expect[k], actual[k], err);
		end
	end

	describe("for HSV", function()
		it("convert from RGB and back within margin of error", function()
			local exp = {getColor("TEAL")}; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, tolerance);
			local exp = {getColor("RED") }; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, tolerance);
			local exp = {.25, .24, .23, 1}; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, tolerance);
			local exp = {.95, .24, .23, 1}; assert_color_near(exp, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(exp)))}, tolerance);
		end)
	end);

	local tolerance = .0025;
	it("converts from HSV to RGB with acceptable tolerance", function()
		local sample = Testsamples[1];
		assert_color_near(sample.RGB, {lib.HSVtoRGB(unpack(sample.HSV))}, tolerance)
	end)

	it("converts from RGB to HSV with acceptable tolerance", function()
		local sample = Testsamples[1];
		assert_color_near(sample.HSV, {lib.RGBtoHSV(unpack(sample.RGB))}, tolerance)
	end)

	it("converts from RGB to HSV and back with acceptable tolerance", function()
		local sample = Testsamples[1];
		assert_color_near(sample.RGB, {lib.HSVtoRGB(lib.RGBtoHSV(unpack(sample.RGB)))}, tolerance)
	end)
end)