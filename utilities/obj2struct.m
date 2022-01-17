function structOut = obj2struct(objIn)

warning('off');
structOut = arrayfun(@struct,objIn);
warning('on');

end

