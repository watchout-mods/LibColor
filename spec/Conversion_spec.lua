describe("Color conversion function", function()
	local lib = require("spec/_Setup");

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

	it("converts correctly from CMYK to RGB", function()
		-- Function does not actually exist yet...
	end)
end)