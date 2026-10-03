local table_helpers = {}

--from http://lua-users.org/wiki/CopyTable
-- This helper function makes a copy of a table and all of its sub-tables
--
-- orig - The original table to be copied
--
-- Returns the new table
local deep_copy
deep_copy = function(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deep_copy(orig_key)] = deep_copy(orig_value)
    end
    setmetatable(copy, deep_copy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end
table_helpers.deep_copy = deep_copy

-- This helper function recursively merges to tables together. Overwriting t1 values with those of t2
--
-- t1 - the table containing values that will be overwritten with values from the t2.
-- t2 - the table containging values to overwrite t1 with
--
-- Example
--    recursive_merge(
--      { outer_table = { inner_table = { mv_val1 = 7, my_val2 = 2 } } },
--      { outer_table = { inner_rable = { my_va11 = 1, my_val3 = 3 } } }
--    )
--    #=> { outer_table = { inner_table = { my_val1 = 1, my_val2 = 2, my_val3 = 3 } } }
--
-- t1 will be modified after calling this function, no need to return anything
local recursive_merge
recursive_merge = function(t1, t2)
  for k,v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k]) == "table" then
        recursive_merge(t1[k], v)
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
end
table_helpers.recursive_merge = recursive_merge

return table_helpers
