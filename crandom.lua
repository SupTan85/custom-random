-- custom random module (16/06/2024) dd:mm:yy
-- >> SupTan!

local crandom = {}
function crandom._random(seed, step, _env)
    _G = _env or _G
    if type(seed) == "number" or tonumber(seed) then
        if step == 0 then
            return tostring(math.floor(seed ^ 2.2)):sub(1, tostring(seed):len())
        elseif tonumber(step) and tonumber(seed) and (tonumber(seed) >= math.maxinteger or step >= math.maxinteger) then
            error("cannot random with this seed. (seed >= maxinteger)")
        end
    else
        return seed
    end
    local function drome(value, min, max)
        local volume = math.max(math.abs(min), math.abs(max)); value = value + min
        return (value - (volume * math.floor(value / volume)))
    end
    local function hex(num)
        local num = tonumber(num)
        local hex = "0123456789ABCDEF"
        local result = ""
        while num ~= 0 do
            local mod = (num % 16) + 1
            result = hex:sub(mod, mod)..result
            num = math.floor(num / 16)
        end
        return result
    end
    if not _G.basicrandom_memory or step == -2 then
        _G.basicrandom_memory = {}
        if step == -2 then
            step = -1
        end
    end
    if not _G.basicrandom_memory.results then
        _G.basicrandom_memory.results = {memory = {}}
    end
    local _step, result, rawresult = step, nil, ""
    local _reresult, lastsave = 0, false
    repeat step, result = _step, ""
        if not _G.basicrandom_memory.step then
            _G.basicrandom_memory.step, _G.basicrandom_memory.lastresult = 0, nil
        else
            _G.basicrandom_memory.step = (_G.basicrandom_memory.step + 1) % math.maxinteger
        end
        if type(_step) ~= "number" then
            step = _G.basicrandom_memory.step * 2
        elseif _step == -1 then
            step = math.floor((_G.basicrandom_memory.step * tonumber("1."..(tostring(seed) or 0))) * 1e3)
            for v in tostring(step):gmatch(".") do
                step = step + tonumber(v) + tostring(_G.basicrandom_memory.step):len()
            end
            step = step % 1e3
        end
        local i, last = 0, ""
        _G.basicrandom_memory.randomresult = _G.basicrandom_memory.randomresult or {}
        for v in tostring(seed):gmatch(".") do
            i = i + 1
            if v == "0" then
                v = (tonumber(last) or 0) + (_G.basicrandom_memory.randomresult[i] or 0) + i
            end
            local calcu = tostring((math.floor(tonumber(v) ^ 1.1) + i + math.floor(step / 2)) % 10)
            result, last = result..calcu, v
            _G.basicrandom_memory.randomresult[i] = calcu
        end
        if lastsave == false then
            _reresult, rawresult = _G.basicrandom_memory.results.memory[hex(result)] or _reresult, result
            lastsave = true
        end
        if _G.basicrandom_memory.results.memory[hex(rawresult)] == _reresult and _step == -1 then
            local result_len = result:len()
            if _reresult % 2 == 0 then
                result = result:reverse()
            end
            result = result:sub(1, math.floor(result_len / 2)):reverse()..result:sub(math.floor(result_len / 2) + 1)
            local seedgmatch, n, u = tostring(result:reverse()):gmatch("."), 0, 0
            result = ""
            for v in seedgmatch do
                n = n + 1
                v = ("%0.0f"):format(math.floor((tonumber(v) + _reresult + ((tonumber(tostring(_reresult):sub(-n, -n)) or 0) + u)) ^ drome(math.min(1.3 + (n / 10), 1e12), 1, 10)) % 10)
                u = math.floor(((tonumber(tostring(_reresult):sub(-n, -n)) or 0) + tonumber(v)) / 10)
                result = v..result
            end
            _reresult = _reresult + 1
        end
    until (_G.basicrandom_memory.lastresult ~= result and _G.basicrandom_memory.results.memory[hex(rawresult)] or -1 < _reresult) or _step ~= -1
    if _step == -1 then
        if not _G.basicrandom_memory.results.block then
            _G.basicrandom_memory.results.block = 1
            _G.basicrandom_memory.results.memory[hex(rawresult)]  = _reresult
        else
            if _G.basicrandom_memory.results.block >= tostring(seed):len() ^ 5 then
                _G.basicrandom_memory.results.memory, _G.basicrandom_memory.results.block = {}, 1
            else
                _G.basicrandom_memory.results.memory[hex(rawresult)],  _G.basicrandom_memory.results.block = _reresult, _G.basicrandom_memory.results.block + 1
            end
        end
        _G.basicrandom_memory.lastresult = result
    end
    return result, _env
end

function crandom.random(self, seed, step)
    seed = tostring(seed)
    local offset, result = seed:len() % 18, ""
    for v in seed:gmatch(("."):rep(18)) do
        result = result..self._random(v, step, self)
    end
    result = offset ~= 0 and result..self._random(seed:sub(-offset), step, self) or result
    return result
end

return crandom