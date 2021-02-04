-- Be sure to define a global vars = {}

local short_maxlen = 23

function Meta(meta)
  for k, v in pairs(meta) do
    if v.t == "MetaInlines" then
      vars["#" .. k .. "#"] = pandoc.utils.stringify(v)
      if string.len(vars["#" .. k .. "#"]) > short_maxlen then
	      vars["#" .. "short_" .. k .. "#"] = vars["#" .. k .. "#"]:sub(1,short_maxlen) .. "..."
	  else
	      vars["#" .. "short_" .. k .. "#"] = vars["#" .. k .. "#"]
	  end
    end
  end
end

