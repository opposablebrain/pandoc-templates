local vars = {}
local word_count = 0
local pandoc_data_dir = os.getenv('PANDOC_DATA_DIR')
local ossep = package.config:sub(1,1)
local hashrule = [[<w:p>
<w:pPr>
  <w:pStyle w:val="BodyText"/>
  <w:ind w:firstLine="0"/>
  <w:jc w:val="center"/>
</w:pPr>
<w:r>
  <w:t>#</w:t>
</w:r>
</w:p>]]

-- Store metadata locally for use in template
function Meta(meta)
  for k, v in pairs(meta) do
    if v.t == "MetaInlines" then
      vars["#" .. k .. "#"] = pandoc.utils.stringify(v)
    end
  end
end

-- HorizontalRule separates scenes with a centered hashtag (#)
-- https://github.com/jgm/pandoc/issues/2573#issuecomment-363839077
function HorizontalRule(el)
    return pandoc.RawBlock('openxml', hashrule)
end

-- Process a docx XML file as a template
function processReferenceFile(referenceFilename)
  local filename = pandoc_data_dir .. ossep .. 'reference' .. ossep .. referenceFilename
  local file = assert(io.open(filename, 'r'))
  local content = file:read("*a")
  file:close()

  for k, v in pairs(vars) do
    if vars[k] == nil then
      content = string.gsub(content, k, '')
    else
      content = string.gsub(content, k, vars[k])
    end
  end

  local file = assert(io.open(filename, 'w'))
  file:write(content)
  file:close()
end

-- Rounding function for word count
function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Blocks for counting words
wordcount = {
  Str = function(el)
    -- we don't count a word if it's entirely punctuation:
    if el.text:match("%P") then
      word_count = word_count + 1
    end
  end,

  Code = function(el)
    _,n = el.text:gsub("%S+","")
    word_count = word_count + n
  end,

  CodeBlock = function(el)
    _,n = el.text:gsub("%S+","")
    word_count = word_count + n
  end
}

-- Inject templating at the document level
function Pandoc(doc, meta)
  pandoc.walk_block(pandoc.Div(doc.blocks), wordcount)

  vars["#word_count#"] = string.format("%i", round(word_count, -2))

  -- Process header XML files
  -- First Page Header
  processReferenceFile('word' .. ossep .. 'header3.xml' )
  -- Subsequent Page Headers
  processReferenceFile('word' .. ossep .. 'header2.xml' )

  -- Generate reference.docx file. OS-dependent.
  -- https://stackoverflow.com/questions/295052/how-can-i-determine-the-os-of-the-system-from-within-a-lua-script
  if ossep == '/' then
    -- *nix (MacOS, Linux) should have zip available
    print("Zipping reference.docx.")
    os.execute ("cd " .. pandoc_data_dir .. "/reference && zip -r ../reference.docx * > /dev/null")
  elseif ossep == '\\' then
    -- Use PowerShell on Windows
    print("Zipping reference.zip.")
    os.execute("powershell.exe Compress-Archive -Path " .. pandoc_data_dir .. "\\reference\\* " .. pandoc_data_dir .. "\\reference.zip")
    print("Renaming reference.zip to reference.docx.")
    os.execute("powershell.exe Rename-Item -Path " .. pandoc_data_dir .. "\\reference.zip -NewName ".. pandoc_data_dir .. "\\reference.docx")
  else
    print("Unknown shell: " .. ossep)
    os.exit(1)
  end
end

