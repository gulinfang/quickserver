local RedisService = class("RedisService")

local RESULT_CONVERTER = {
    exists = {
        RedisLuaAdapter = function(self, r)
            if r == true then
                return 1
            else
                return 0
            end
        end,
    },

    hgetall = {
        RestyRedisAdapter = function(self, r)
            return self:arrayToHash(r)
        end,
    },
}

local adapter 
if ngx then 
    adapter = import(".adapter.RestyRedisAdapter")
else
    adapter = import(".adapter.RedisLuaAdapter")
end
local trans = import(".RedisTransaction")
local pipline = import(".RedisPipeline")

function RedisService:ctor(config) 
    if not config or type(config) ~= "table" then 
        return nil, "config is invalid."
    end

    self.config = config or {host = "127.0.0.1", port = 6379, timeout = 10*1000}
    self.redis = adapter.new(self.config)
end

function RedisService:connect()
    local redis = self.redis
    if not redis then 
        return nil, "Package redis is not initialized."    
    end

    return redis:connect()
end

function RedisService:close() 
    local redis = self.redis
    if not redis then 
        return nil, "Package redis is not initialized."    
    end

    return redis:close()
end

function RedisService:command(command, ...)
    local redis = self.redis
    if not redis then 
        return nil, "Package redis is not initialized."    
    end

    command = string.lower(command)
    local res, err = redis:command(command, ...)
    if not err then
        -- converting result
        local convert = RESULT_CONVERTER[command]
        if convert and convert[redis.name] then
            res = convert[redis.name](self, res)
        end
    end

    return res, err
end

function RedisService:pubsub(subscriptions)
    local redis = self.redis
    if not redis then 
        return nil, "Package redis is not initialized."    
    end

    return self.redis:pubsub(subscriptions)
end

function RedisService:newPipeline()
    return pipline.new(self)
end

function RedisService:newTransaction(...)
    return trans.new(self, ...)
end

function RedisService:hashToArray(hash)
    local arr = {}
    for k, v in pairs(hash) do
        arr[#arr + 1] = k
        arr[#arr + 1] = v
    end

    return arr
end

function RedisService:arrayToHash(arr)
    local c = #arr
    local hash = {}
    for i = 1, c, 2 do
        hash[arr[i]] = arr[i + 1]
    end

    return hash
end

return RedisService