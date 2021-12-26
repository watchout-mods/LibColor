describe("LibColor", function()
	local lib = require("spec/_Setup");

	it("methods take a list of three numbers as a color argument", function()
		assert.are.same({1, 1, 1}, {lib:GetColor(1, 1, 1)});
		assert.are.same({0, 0, 0}, {lib:GetColor(0, 0, 0)});
	end)

	it("methods take a color name as a color argument", function()
		assert.are.same({1, 0, 0, 1}, {lib:GetColor('RED')});
	end)

	it("methods take a three-channel color table as a color argument", function()
		assert.are.same({1, 0, 0}, {lib:GetColor({1, 0, 0})});
	end)

	it("methods take a four-channel color table as a color argument", function()
		assert.are.same({1, 0, 0, 1}, {lib:GetColor({1, 0, 0, 1})});
	end)
end)