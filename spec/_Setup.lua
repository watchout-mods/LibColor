PowerBarColor = {};
RAID_CLASS_COLORS = {};

floor = function(...)
	print("FIXME: remove the call to this function, instead use math.floor");

	return math.floor(...);
end

function strjoin(sep, ...)
	print("TODO: avoid the call to this function");
	local args = {...};
	for i=1, #args do
		args[i] = tostring(args[i]);
	end
	return table.concat(args, sep);
end

function tostringall(...)
	print("FIXME: remove the call to this function");
	local args = {...};
	for i=1, #args do
		args[i] = tostring(args[i]);
	end
	return unpack(args);
end

require("spec/LibStub");
require("LibColor");

return LibStub("LibColor-1");