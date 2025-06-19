local github_base = "https://raw.githubusercontent.com/StuartAndMath/cc-influxdb-collectors/main/"

local files = {
  "influxdb.lua",
  "collectors.lua",
  "me_bridge_collector.lua"
}

for _, file in ipairs(files) do
  print("Downloading " .. file .. " ...")
  if fs.exists(file) then
    fs.delete(file)
  end
  local ok, err = pcall(function()
    shell.run("wget", github_base .. file, file)
  end)
  if ok then
    print(file .. " downloaded successfully.")
  else
    print("Failed to download " .. file .. ": " .. tostring(err))
  end
end
