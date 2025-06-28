```
wget run https://raw.githubusercontent.com/StuartAndMath/cc-influxdb-collectors/main/setup.lua
```

**Example**

```lua
local influxdb = require("influxdb")
local collectors = require("collectors")

-- InfluxDB settings
local influx_host = "" -- without http://
local influx_org = ""
local influx_bucket = ""
local influx_token = ""

local influx = influxdb.initialize {
  ip = influx_host,
  token = influx_token,
  org = influx_org
}

local collector = collectors.bigreactor(BigReactors-Reactor_2)

while true do
  local stats, err = collector.collect()

  if not stats then
    print("Failed to collect stats:", err)
    os.sleep(5)
    goto continue
  end

  local ok, err = influx.publish(
    influx_bucket,
    "measurement_name",
    stats
  )
  if not ok then
    print("Failed to post to InfluxDB:", err)
  end

  os.sleep(5)  -- Adjust the sleep time as needed
  ::continue::
end
```
