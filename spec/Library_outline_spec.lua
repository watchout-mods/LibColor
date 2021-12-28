describe("LibColor", function()
	local Lib = require("spec/_Setup");

	it("methods are called without errors", function()
		assert.is.True(Lib:IsColorTable({1, 0, 1}));
		assert.is.True(Lib:IsColorTable({1, 0, 1, 0}));
		assert.is.True(Lib:IsBlizColorTable({r = 1, g = 0, b = 1}));
		assert.is.True(Lib:IsBlizColorTable({r = 1, g = 0, b = 1, a = 0}));

		assert.is.True(Lib:IsColor(Lib:GetColor('RED')));
		assert.is.True(Lib:IsColorList(Lib:GetColor('RED')));
		assert.is.True(Lib:IsColorName('RED'));

		assert.is.Function(Lib:CreateColorBlender('RED', 'BLUE'));
		assert.is.True(Lib:IsColor(Lib:BlendColor('RED', 'BLUE', .5)));

		assert.is.True(Lib:IsColor(Lib:Desaturate('RED')));
		assert.is.True(Lib:IsColor(Lib:ModifyLuminosity_old(0.1, 'RED')));
		assert.is.Number(Lib:GetLuminosity('RED'));
		assert.is.True(Lib:IsColor(Lib:ModifyLuminosity(0.2, 'RED')));
		assert.is.True(Lib:IsColor(Lib:SetLuminosity(0.2, 'RED')));

		assert.is.True(Lib:IsColor(Lib:GetColorForText('RED')));

		assert.is.True(Lib:IsColor(Lib.RGBtoHSL(1, 1, 1, 1)));
		assert.is.True(Lib:IsColor(Lib.HSLtoRGB(1, 1, 1, 1)));
		assert.is.True(Lib:IsColor(Lib.RGBtoHSV(1, 1, 1, 1)));
		assert.is.True(Lib:IsColor(Lib.HSVtoRGB(1, 1, 1, 1)));
	end)
end)