describe("Color conversion function", function()
	local Lib = require("spec/_Setup");

	-- samples taken from https://color.adobe.com/create/color-wheel/
	-- "HSB" equals "HSV" here
	Testsamples = {
		{ -- color
			CMYK = {0, 66, 32, 61},
			RGB = {100, 34, 69},
			LAB = {25, 33, -6},
			HSV = {328, 66, 39}, -- (H: 0 ... 359)
		}
	}
	-- Convert color to internal representation
	for k, value in pairs(Testsamples) do
		do -- Convert RGB
			local r, g, b = unpack(value.RGB);
			r = r / 255;
			g = g / 255;
			b = b / 255;
			value.RGB = {r, g, b};
		end
		do -- Convert HSV
			local h, s, v = unpack(value.HSV);
			h = h / 360;
			s = s / 100;
			v = v / 100;
			value.HSV = {h, s, v};
		end
	end

	it("converts from HSV to RGB with acceptable tolerance", function()
		local tolerance = .0025;
		local sample = Testsamples[1];
		local r, g, b, a = Lib.HSVtoRGB(unpack(sample.HSV));
		assert.are.Near(sample.RGB[1], r, tolerance);
		assert.are.Near(sample.RGB[2], g, tolerance);
		assert.are.Near(sample.RGB[3], b, tolerance);
	end)

	it("converts from RGB to HSV with acceptable tolerance", function()
		local tolerance = .0025;
		local sample = Testsamples[1];
		local h, s, v, a = Lib.RGBtoHSV(unpack(sample.RGB));
		assert.are.Near(sample.HSV[1], h, tolerance);
		assert.are.Near(sample.HSV[2], s, tolerance);
		assert.are.Near(sample.HSV[3], v, tolerance);
	end)

	it("converts from RGB to HSV and back with acceptable tolerance", function()
		local tolerance = .000001;
		local sample = Testsamples[1];
		local r, g, b, a = Lib.HSVtoRGB(Lib.RGBtoHSV(unpack(sample.RGB)));
		assert.are.Near(sample.RGB[1], r, tolerance);
		assert.are.Near(sample.RGB[2], g, tolerance);
		assert.are.Near(sample.RGB[3], b, tolerance);
	end)
end)