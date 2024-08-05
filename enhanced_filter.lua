-- typography.lua

-- Function to remove unnecessary whitespace and replace with backslash
function remove_whitespace(str)
  return str:gsub("%s+", "\\")
end

-- Function to process inline elements
function process_inlines(inlines)
  local new_inlines = {}
  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      table.insert(new_inlines, pandoc.Str(remove_whitespace(inline.text)))
    else
      table.insert(new_inlines, inline)
    end
  end
  return new_inlines
end

-- Function to process block elements
function process_blocks(blocks)
  local new_blocks = {}
  for _, block in ipairs(blocks) do
    if block.t == "Para" or block.t == "Plain" then
      table.insert(new_blocks, pandoc.Para(process_inlines(block.content)))
    elseif block.t == "BulletList" or block.t == "OrderedList" then
      local new_list = {}
      for _, item in ipairs(block.content) do
        local new_item = {}
        for _, subitem in ipairs(item) do
          if subitem.t == "Plain" or subitem.t == "Para" then
            table.insert(new_item, pandoc.Plain(process_inlines(subitem.content)))
          else
            table.insert(new_item, subitem)
          end
        end
        table.insert(new_list, new_item)
      end
      if block.t == "BulletList" then
        table.insert(new_blocks, pandoc.BulletList(new_list))
      else
        table.insert(new_blocks, pandoc.OrderedList(new_list))
      end
    else
      table.insert(new_blocks, block)
    end
  end
  return new_blocks
end

-- Walk through all elements in the document
function Pandoc(doc)
  local new_blocks = process_blocks(doc.blocks)
  return pandoc.Pandoc(new_blocks, doc.meta)
end

