-- influxdb.lua
-- A generic InfluxDB client for ComputerCraft

local function influxdb_init(params)
    assert(type(params) == "table", "params must be a table")
    local ip = assert(params.ip, "ip is required")
    local token = assert(params.token, "token is required")
    local org = assert(params.org, "org is required")

    local function publish(bucket, measurement, fields, tags)
        assert(type(bucket) == "string", "bucket must be a string")
        assert(type(measurement) == "string", "measurement must be a string")
        assert(type(fields) == "table", "fields must be a table")
        tags = tags or {}
        assert(type(tags) == "table", "tags must be a table")

        -- Construct line protocol
        local tag_str = ""
        for k, v in pairs(tags) do
            tag_str = tag_str .. "," .. k .. "=" .. tostring(v)
        end
        local field_str = ""
        for k, v in pairs(fields) do
            if #field_str > 0 then field_str = field_str .. "," end
            if type(v) == "string" then
                field_str = field_str .. k .. '="' .. v .. '"'
            else
                field_str = field_str .. k .. "=" .. tostring(v)
            end
        end
        local line = measurement .. tag_str .. " " .. field_str

        -- Prepare HTTP request
        local url = "http://" .. ip .. "/api/v2/write?org=" .. org .. "&bucket=" .. bucket .. "&precision=s"
        local headers = {
            ["Authorization"] = "Token " .. token,
            ["Content-Type"] = "text/plain"
        }
        local body = line
        local ok, err = http and http.post(url, body, headers)
        if not ok then
            return false, err or "HTTP POST failed"
        end
        if ok.getResponseCode and ok.getResponseCode() >= 300 then
            return false, ok.readAll() or "InfluxDB error"
        end
        if ok.readAll then ok.readAll() end
        if ok.close then ok.close() end
        return true
    end

    -- Flush (delete) all data from a bucket
    local function flush_bucket(bucket)
        assert(type(bucket) == "string", "bucket must be a string")
        -- InfluxDB delete API: POST /api/v2/delete?org=ORG&bucket=BUCKET
        local url = "http://" .. ip .. "/api/v2/delete?org=" .. org .. "&bucket=" .. bucket
        local headers = {
            ["Authorization"] = "Token " .. token,
            ["Content-Type"] = "application/json"
        }
        -- Delete everything: start = 1970-01-01T00:00:00Z, stop = now
        local now = os.epoch and os.epoch("utc") or os.time()
        local stop = os.date("!%Y-%m-%dT%H:%M:%SZ", now)
        local body = '{"start":"1970-01-01T00:00:00Z","stop":"' .. stop .. '"}'
        local ok, err = http and http.post(url, body, headers)
        if not ok then
            return false, err or "HTTP POST failed"
        end
        if ok.getResponseCode and ok.getResponseCode() >= 300 then
            return false, ok.readAll() or "InfluxDB error"
        end
        if ok.readAll then ok.readAll() end
        if ok.close then ok.close() end
        return true
    end

    return {
        publish = publish,
        flush_bucket = flush_bucket
    }
end

return {
    initialize = influxdb_init
}
