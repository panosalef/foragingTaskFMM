function structOut = obj2struct(objIn)
%OBJ2STRUCT  Convert an array of handle objects to an array of plain structs.

warning('off');
structOut = arrayfun(@struct,objIn);
warning('on');

end

