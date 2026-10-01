--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║  NANG RBXM v64.0 - Dark Green Edition                              ║
    ║  VIP: Akses penuh via UserId whitelist                             ║
    ║  FREE: Semua fitur via Key System (key dikirim ke Discord owner)   ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

-- NANG SAFE EXECUTE WRAPPER
-- Semua inisialisasi dijalankan di dalam xpcall agar error pada fitur opsional
-- tidak membuat script berhenti tanpa pesan.
local __NANG_MAIN_OK = false
local __NANG_MAIN_ERR = nil

local function __NANG_RUN_MAIN()
    if not game:IsLoaded() then
        pcall(function() game.Loaded:Wait() end)
    end


-- ═══════════════════════════════════════════════════════════════════════
-- ACCESS GATE — WHITELIST ONLY
-- ═══════════════════════════════════════════════════════════════════════
-- Hanya UserId yang terdaftar di _WHITELIST yang boleh menggunakan NANG RBXM.
-- UserId lain langsung dikeluarkan dan tidak pernah membuat UI utama.
local _WHITELIST = {
    10370966620,
    8153244285,
    9218615280,
    9810200508,
    9451353705,
    8236629801,
    10825136275,
    8902706566,
    7355968889,
    10774723762,
    9214202918,
    11191545522,
    11264166178,
    172732271,
    9100523005,
    9516448806,
    10950645546,
    11004255643,
    8356649880,
    10363021496,
    8768936755,
    7900111839,
    9411784854,
    8785695722,
    10109081111,
    7141939467,
    8877803873,
    11691396808,
    8521600747,
    9539495160,
    8399819232,
}

local _player = game:GetService("Players").LocalPlayer
local _userId = _player.UserId
local _isVIP = false

for _, id in ipairs(_WHITELIST) do
    if id == _userId then
        _isVIP = true
        break
    end
end

-- ═══════════════════════════════════════════════════════════════════════
-- KEY SYSTEM — Free access via website key (expired 24 jam, validasi lokal)
-- ═══════════════════════════════════════════════════════════════════════
local KEY_SITE = "https://nang-key.vercel.app"
local KEY_SECRET = "NANG2024"

-- Hitung time window (berubah tiap 24 jam)
local function getTimeWindow()
    return math.floor(os.time() / 86400)
end

-- Hash simpel: sama persis dengan JS di website
local function simpleHash(str)
    local h = 0
    for i = 1, #str do
        h = (h * 31 + string.byte(str, i)) % 1000000007
    end
    return h
end

-- Generate key dari userId + window
local function generateKeyLocal(userId, window)
    local raw = KEY_SECRET .. tostring(userId) .. tostring(window)
    local h = simpleHash(raw)
    local uid = tostring(userId)
    local part1 = uid:sub(1, math.min(5, #uid))
    while #part1 < 5 do part1 = part1 .. "0" end
    local part2 = string.format("%04d", h % 10000)
    local part3 = string.format("%04d", math.floor(h / 10000) % 10000)
    return "NANG-" .. part1 .. "-" .. part2 .. "-" .. part3
end

-- Validate key lokal
local function validateKeyOnline(userId, key, callback)
    local w = getTimeWindow()
    local input = string.upper(tostring(key)):gsub("%s+","")
    local valid = (input == generateKeyLocal(userId, w))
               or (input == generateKeyLocal(userId, w - 1))
    callback(valid)
end

-- Event untuk lanjutkan script setelah key valid
_G.__NANG_KEY_EVENT = Instance.new("BindableEvent")
local _keyPassed = false
_G.__NANG_KEY_EVENT.Event:Connect(function()
    _keyPassed = true
end)

if not _isVIP then
    local _playerName = _player.DisplayName or _player.Name or "Unknown"
    local _keyLink = KEY_SITE .. "/?uid=" .. tostring(_userId)

    local TweenService2 = game:GetService("TweenService")
    local CoreGui2 = game:GetService("CoreGui")
    local CoreDest2 = CoreGui2
    pcall(function() if not CoreDest2 then CoreDest2 = _player:WaitForChild("PlayerGui") end end)

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "NANG_KEY_GUI"
    KeyGui.ResetOnSpawn = false
    KeyGui.DisplayOrder = 9999
    KeyGui.IgnoreGuiInset = true
    KeyGui.Parent = CoreDest2

    local Overlay = Instance.new("Frame", KeyGui)
    Overlay.Size = UDim2.new(1,0,1,0)
    Overlay.BackgroundColor3 = Color3.fromRGB(3,8,3)
    Overlay.BackgroundTransparency = 0.3
    Overlay.BorderSizePixel = 0

    local Card = Instance.new("Frame", KeyGui)
    Card.AnchorPoint = Vector2.new(0.5,0.5)
    Card.Position = UDim2.new(0.5,0,0.5,0)
    Card.Size = UDim2.new(0,400,0,362)
    Card.BackgroundColor3 = Color3.fromRGB(8,22,8)
    Card.BorderSizePixel = 0
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0,16)
    local CardStroke = Instance.new("UIStroke", Card)
    CardStroke.Color = Color3.fromRGB(34,139,34)
    CardStroke.Thickness = 1.5

    local AccentBar = Instance.new("Frame", Card)
    AccentBar.Size = UDim2.new(1,0,0,4)
    AccentBar.Position = UDim2.new(0,0,0,0)
    AccentBar.BackgroundColor3 = Color3.fromRGB(40,160,40)
    AccentBar.BorderSizePixel = 0
    Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0,16)

    local Logo = Instance.new("TextLabel", Card)
    Logo.Size = UDim2.new(1,-40,0,36)
    Logo.Position = UDim2.new(0,20,0,18)
    Logo.BackgroundTransparency = 1
    Logo.Text = "NANG RBXM"
    Logo.TextColor3 = Color3.fromRGB(40,160,40)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 22
    Logo.TextXAlignment = Enum.TextXAlignment.Center

    local Sub = Instance.new("TextLabel", Card)
    Sub.Size = UDim2.new(1,-40,0,28)
    Sub.Position = UDim2.new(0,20,0,54)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Buka link di bawah, masukkan UserId kamu, lalu copy keynya."
    Sub.TextColor3 = Color3.fromRGB(80,160,80)
    Sub.Font = Enum.Font.Gotham
    Sub.TextSize = 9
    Sub.TextXAlignment = Enum.TextXAlignment.Center
    Sub.TextWrapped = true

    -- Link box
    local LinkBox = Instance.new("Frame", Card)
    LinkBox.Size = UDim2.new(1,-40,0,38)
    LinkBox.Position = UDim2.new(0,20,0,92)
    LinkBox.BackgroundColor3 = Color3.fromRGB(5,15,5)
    LinkBox.BorderSizePixel = 0
    Instance.new("UICorner", LinkBox).CornerRadius = UDim.new(0,8)
    local LinkStroke = Instance.new("UIStroke", LinkBox)
    LinkStroke.Color = Color3.fromRGB(20,80,20)
    LinkStroke.Thickness = 1
    local LinkLbl = Instance.new("TextLabel", LinkBox)
    LinkLbl.Size = UDim2.new(1,-16,1,0)
    LinkLbl.Position = UDim2.new(0,8,0,0)
    LinkLbl.BackgroundTransparency = 1
    LinkLbl.Text = _keyLink
    LinkLbl.TextColor3 = Color3.fromRGB(60,200,60)
    LinkLbl.Font = Enum.Font.Code
    LinkLbl.TextSize = 8
    LinkLbl.TextXAlignment = Enum.TextXAlignment.Left
    LinkLbl.TextTruncate = Enum.TextTruncate.AtEnd

    -- Tombol salin link
    local CopyLinkBtn = Instance.new("TextButton", Card)
    CopyLinkBtn.Size = UDim2.new(1,-40,0,34)
    CopyLinkBtn.Position = UDim2.new(0,20,0,138)
    CopyLinkBtn.BackgroundColor3 = Color3.fromRGB(18,65,18)
    CopyLinkBtn.BorderSizePixel = 0
    CopyLinkBtn.Text = "📋  SALIN LINK"
    CopyLinkBtn.TextColor3 = Color3.fromRGB(80,220,80)
    CopyLinkBtn.Font = Enum.Font.GothamBold
    CopyLinkBtn.TextSize = 11
    Instance.new("UICorner", CopyLinkBtn).CornerRadius = UDim.new(0,8)
    local CLStroke = Instance.new("UIStroke", CopyLinkBtn)
    CLStroke.Color = Color3.fromRGB(30,100,30)
    CLStroke.Thickness = 1
    CopyLinkBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(_keyLink) end)
        CopyLinkBtn.Text = "✓  LINK TERSALIN!"
        CopyLinkBtn.TextColor3 = Color3.fromRGB(120,255,120)
        task.wait(2)
        CopyLinkBtn.Text = "📋  SALIN LINK"
        CopyLinkBtn.TextColor3 = Color3.fromRGB(80,220,80)
    end)

    -- Info userid
    local UidLbl = Instance.new("TextLabel", Card)
    UidLbl.Size = UDim2.new(1,-40,0,22)
    UidLbl.Position = UDim2.new(0,20,0,180)
    UidLbl.BackgroundTransparency = 1
    UidLbl.Text = "UserId kamu: " .. tostring(_userId) .. " (sudah auto-isi di link)"
    UidLbl.TextColor3 = Color3.fromRGB(50,120,50)
    UidLbl.Font = Enum.Font.GothamBold
    UidLbl.TextSize = 9
    UidLbl.TextXAlignment = Enum.TextXAlignment.Center

    -- Key input
    local KeyBox = Instance.new("TextBox", Card)
    KeyBox.Size = UDim2.new(1,-40,0,44)
    KeyBox.Position = UDim2.new(0,20,0,212)
    KeyBox.BackgroundColor3 = Color3.fromRGB(9,24,9)
    KeyBox.BorderSizePixel = 0
    KeyBox.ClearTextOnFocus = false
    KeyBox.PlaceholderText = "Paste key disini... (NANG-XXXXX-XXXX-XXXX)"
    KeyBox.Text = ""
    KeyBox.TextColor3 = Color3.fromRGB(200,255,200)
    KeyBox.PlaceholderColor3 = Color3.fromRGB(40,100,40)
    KeyBox.Font = Enum.Font.Code
    KeyBox.TextSize = 10
    KeyBox.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0,8)
    local KeyBoxStroke = Instance.new("UIStroke", KeyBox)
    KeyBoxStroke.Color = Color3.fromRGB(34,139,34)
    KeyBoxStroke.Thickness = 1
    local KeyPad = Instance.new("UIPadding", KeyBox)
    KeyPad.PaddingLeft = UDim.new(0,10)

    local StatusLbl = Instance.new("TextLabel", Card)
    StatusLbl.Size = UDim2.new(1,-40,0,20)
    StatusLbl.Position = UDim2.new(0,20,0,262)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "Key expired otomatis setiap 24 jam"
    StatusLbl.TextColor3 = Color3.fromRGB(40,100,40)
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextSize = 9
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Center

    local SubmitBtn = Instance.new("TextButton", Card)
    SubmitBtn.Size = UDim2.new(1,-40,0,42)
    SubmitBtn.Position = UDim2.new(0,20,0,290)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(30,110,30)
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Text = "VERIFIKASI KEY"
    SubmitBtn.TextColor3 = Color3.new(1,1,1)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.TextSize = 13
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0,10)

    local _submitting = false
    local function tryKey()
        if _submitting then return end
        local input = tostring(KeyBox.Text):gsub("%s+",""):upper()
        if input == "" then
            StatusLbl.Text = "⚠ Key tidak boleh kosong"
            StatusLbl.TextColor3 = Color3.fromRGB(220,80,80)
            return
        end
        _submitting = true
        SubmitBtn.Text = "MENGECEK..."
        StatusLbl.Text = "Memvalidasi ke server..."
        StatusLbl.TextColor3 = Color3.fromRGB(80,180,80)

        validateKeyOnline(_userId, input, function(valid, errMsg)
            if valid then
                StatusLbl.Text = "✓ Key valid! Memuat..."
                StatusLbl.TextColor3 = Color3.fromRGB(80,220,80)
                SubmitBtn.Text = "BERHASIL ✓"
                task.wait(0.7)
                KeyGui:Destroy()
                _isVIP = true
                _G.__NANG_KEY_PASSED = true
                -- Jalankan sisa script di thread baru
                task.spawn(function()
                    local ok, err = xpcall(function()
                        loadstring(game:HttpGet and "" or "")()
                    end, function(e) return e end)
                end)
                -- Trigger continue dengan cara set BindableEvent
                _G.__NANG_KEY_EVENT:Fire()
            else
                StatusLbl.Text = "✗ Key salah/expired. Generate ulang di website."
                StatusLbl.TextColor3 = Color3.fromRGB(220,80,80)
                SubmitBtn.Text = "VERIFIKASI KEY"
                TweenService2:Create(Card, TweenInfo.new(0.05), {Position = UDim2.new(0.5,7,0.5,0)}):Play()
                task.wait(0.05)
                TweenService2:Create(Card, TweenInfo.new(0.05), {Position = UDim2.new(0.5,-7,0.5,0)}):Play()
                task.wait(0.05)
                TweenService2:Create(Card, TweenInfo.new(0.05), {Position = UDim2.new(0.5,0,0.5,0)}):Play()
                _submitting = false
            end
        end)
    end

    SubmitBtn.MouseButton1Click:Connect(tryKey)
    KeyBox.FocusLost:Connect(function(enter) if enter then tryKey() end end)

    -- Tunggu sampai key valid (tidak return, tapi block di sini)
    repeat task.wait(0.1) until _keyPassed
end

-- ═══════════════════════════════════════════════════════════════════════
-- SERVICES & UTILITIES
-- ═══════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local CoreDest = pcall(function() return CoreGui.Name end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

_G.LANGZ_RAW_SOURCES = _G.LANGZ_RAW_SOURCES or {}


-- Pemetaan Icon Vektor Lucide (High Resolution & Clean Vector Mask)
local ICONS = {
    PACKAGE        = "rbxassetid://10709791437",
    SEARCH         = "rbxassetid://10709796118",
    CLOSE          = "rbxassetid://10709790644",
    MINIMIZE       = "rbxassetid://10709790387",
    CHEVRON_RIGHT  = "rbxassetid://10709782525",
    CHEVRON_LEFT   = "rbxassetid://10709782230",
    BELL           = "rbxassetid://10709791160",
    GAMEPAD        = "rbxassetid://10709790082",
    FILE           = "rbxassetid://10709790948",
    DOWNLOAD       = "rbxassetid://10709791283",
    CHECK          = "rbxassetid://10709790240",
    ALERT          = "rbxassetid://10709790520",
    FOLDER         = "rbxassetid://10709790172",
    REFRESH        = "rbxassetid://10709793382"
}

-- ═══════════════════════════════════════════════════════════════════════
-- HTTP REQUEST UTILITY
-- ═══════════════════════════════════════════════════════════════════════
local function httpRequest(url, method, headers, data)
    method = method or "GET"
    headers = headers or {}
    headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"

    local requestFuncs = {
        function() if syn and syn.request then local r = syn.request({Url = url, Method = method, Headers = headers, Body = data}); return r.Body, r.StatusCode end end,
        function() if request then local r = request({Url = url, Method = method, Headers = headers, Body = data}); return r.Body, r.StatusCode end end,
        function() if http_request then local r = http_request({Url = url, Method = method, Headers = headers, Body = data}); return r.Body, r.StatusCode end end,
        function() if fluxus and fluxus.request then local r = fluxus.request({Url = url, Method = method, Headers = headers, Body = data}); return r.Body, r.StatusCode end end,
        function() return HttpService:GetAsync(url, true), 200 end,
        function() return game:HttpGet(url, true), 200 end
    }
    for _, fn in ipairs(requestFuncs) do
        local ok, body, status = pcall(fn)
        if ok and body and type(body) == "string" and #body > 0 then
            return body, status or 200
        end
    end
    return nil, nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- RBXM FILE PARSER (LZ4 + Binary Format)
-- ═══════════════════════════════════════════════════════════════════════
local function Buffer(str, allowOverflows)
    local Stream = { Offset = 0, Source = str, Length = string.len(str), AllowOverflows = (allowOverflows == nil and true) or allowOverflows }
    function Stream:read(len, shift)
        len = len or 1; shift = (shift == nil and true) or shift
        local dat = string.sub(self.Source, self.Offset + 1, self.Offset + len)
        if shift then self:seek(len) end
        return dat
    end
    function Stream:seek(len) self.Offset = math.clamp(self.Offset + len, 0, self.Length) end
    function Stream:readNumber(fmt, shift)
        fmt = fmt or "I1"; local chunk = self:read(string.packsize(fmt), shift); return string.unpack(fmt, chunk)
    end
    function Stream:append(s) self.Source = self.Source .. s; self.Length = #self.Source end
    function Stream:toEnd() self.Offset = self.Length end
    return Stream
end

local function transformInt(x) return (x % 2 == 0) and (x / 2) or (-(x + 1) / 2) end
local function rbxF32(x) x = bit32.rrotate(x, 1); return string.unpack(">f", string.pack(">I4", x)) end

local basicTypes = {}
function basicTypes.String(buffer) return buffer:read(buffer:readNumber("<I4")) end
function basicTypes.Int32(buffer) return transformInt(buffer:readNumber(">I4")) end
function basicTypes.Int64(buffer) return transformInt(buffer:readNumber(">I8")) end
function basicTypes.Float32(buffer) return rbxF32(buffer:readNumber(">I4")) end
function basicTypes.Float64(buffer) return buffer:readNumber("<d") end

function basicTypes.InterleaveArrayWithSize(buffer, count, sizeof)
    if count < 0 then return Buffer("", false) end
    local stream = buffer:read(count * sizeof); local out = table.create(count)
    for i = 1, count do
        local chunk = table.create(sizeof)
        for s = 0, sizeof - 1 do
            local bitPos = i + (count * s); chunk[s+1] = string.sub(stream, bitPos, bitPos)
        end
        out[i] = table.concat(chunk)
    end
    return Buffer(table.concat(out), false)
end

function basicTypes.unsignedIntArray(buffer, count)
    if count < 1 then return {} end
    local o = table.create(count); local strings = basicTypes.InterleaveArrayWithSize(buffer, count, 4)
    for i = 1, count do o[i] = strings:readNumber("<I4") end
    return o
end

function basicTypes.Int32Array(buffer, count)
    if count < 1 then return {} end
    local o = table.create(count); local strings = basicTypes.InterleaveArrayWithSize(buffer, count, 4)
    for i = 1, count do o[i] = basicTypes.Int32(strings) end
    return o
end

function basicTypes.Int64Array(buffer, count)
    if count < 1 then return {} end
    local o = table.create(count); local strings = basicTypes.InterleaveArrayWithSize(buffer, count, 8)
    for i = 1, count do o[i] = basicTypes.Int64(strings) end
    return o
end

function basicTypes.RbxF32Array(buffer, count)
    if count < 1 then return {} end
    local o = table.create(count); local strings = basicTypes.InterleaveArrayWithSize(buffer, count, 4)
    for i = 1, count do o[i] = basicTypes.Float32(strings) end
    return o
end

function basicTypes.RefArray(buffer, count)
    if count < 1 then return {} end
    local o = table.create(count); local refs = basicTypes.Int32Array(buffer, count); local last = 0
    for i = 1, count do local ref = last + refs[i]; o[i] = ref; last = ref end
    return o
end

local function lz4(lz4data)
    local inputStream = Buffer(lz4data)
    local compressedLen = string.unpack("<I4", inputStream:read(4))
    local decompressedLen = string.unpack("<I4", inputStream:read(4))
    local reserved = string.unpack("<I4", inputStream:read(4))
    if reserved ~= 0 then error("not lz4") end
    if compressedLen == 0 then return inputStream:read(decompressedLen) end
    local outputStream = Buffer("")
    repeat
        local token = string.byte(inputStream:read())
        local litLen = bit32.rshift(token, 4)
        local matLen = bit32.band(token, 15) + 4
        if litLen >= 15 then
            repeat local nextByte = string.byte(inputStream:read()); litLen = litLen + nextByte until nextByte ~= 0xFF
        end
        local literal = inputStream:read(litLen); outputStream:append(literal); outputStream:toEnd()
        if outputStream.Length < decompressedLen then
            local offset = string.unpack("<I2", inputStream:read(2))
            if matLen >= 19 then
                repeat local nextByte = string.byte(inputStream:read()); matLen = matLen + nextByte until nextByte ~= 0xFF
            end
            outputStream:seek(-offset)
            local pos = outputStream.Offset; local match = outputStream:read(matLen)
            local unreadBytes = outputStream.LastUnreadBytes or 0
            local extra
            if unreadBytes then
                repeat
                    outputStream.Offset = pos; extra = outputStream:read(unreadBytes)
                    unreadBytes = outputStream.LastUnreadBytes or 0; match = match .. extra
                until unreadBytes <= 0
            end
            outputStream:append(match); outputStream:toEnd()
        end
    until outputStream.Length >= decompressedLen
    return outputStream.Source
end

local function b64encode(str)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local out = {}
    for i = 1, #str, 3 do
        local b0, b1, b2 = string.byte(str, i, i+2)
        local b = bit32.lshift(b0, 16) + bit32.lshift(b1 or 0, 8) + (b2 or 0)
        table.insert(out, chars:sub(bit32.extract(b, 18, 6)+1, bit32.extract(b, 18, 6)+1))
        table.insert(out, chars:sub(bit32.extract(b, 12, 6)+1, bit32.extract(b, 12, 6)+1))
        table.insert(out, b1 and chars:sub(bit32.extract(b, 6, 6)+1, bit32.extract(b, 6, 6)+1) or "=")
        table.insert(out, b2 and chars:sub(bit32.band(b, 63)+1, bit32.band(b, 63)+1) or "=")
    end
    return table.concat(out)
end

local function zstd(stream)
    local zbase64 = b64encode(stream)
    local json = '{"m":null,"t":"buffer","zbase64":"' .. zbase64 .. '"}'
    local x = HttpService:JSONDecode(json)
    return buffer.tostring(x)
end

local function parseRBXMForSources(data)
    local sources = {}
    local rbxmBuffer = Buffer(data, false)
    if rbxmBuffer:read(8) ~= "<roblox!" or rbxmBuffer:read(6) ~= "\x89\xff\x0d\x0a\x1a\x0a" then return sources, "Invalid header" end
    if rbxmBuffer:read(2) ~= (string.char(0)..string.char(0)) then return sources, "Invalid version" end
    local classCount = rbxmBuffer:readNumber("<i4")
    local instCount = rbxmBuffer:readNumber("<i4")
    local classRefs, virtualInstances, strings, chunkInfo = {}, {}, {}, {}
    local valid_end_chunk = "END"..string.char(0)
    local valid = {[valid_end_chunk]=true, ["INST"]=true, ["META"]=true, ["PRNT"]=true, ["PROP"]=true, ["SIGN"]=true, ["SSTR"]=true}
    for k in pairs(valid) do chunkInfo[k] = {} end
    if rbxmBuffer:read(8) ~= string.char(0,0,0,0,0,0,0,0) then return sources, "Invalid header" end

    local index, last_chunk = 0, nil
    repeat
        index = index + 1
        local chunk = {InternalID = index, Header = rbxmBuffer:read(4)}
        if not valid[chunk.Header] then return sources, "Invalid chunk" end
        local lz4Header = rbxmBuffer:read(16, false)
        local compressed = string.unpack("<I4", string.sub(lz4Header, 1, 4))
        local decompressed = string.unpack("<I4", string.sub(lz4Header, 5, 8))
        local reserved = string.sub(lz4Header, 9, 12)
        local zstd_check = string.sub(lz4Header, 13, 16)
        local dataChunk
        if compressed == 0 then
            dataChunk = rbxmBuffer:read(decompressed + 12)
        else
            if zstd_check == "\x28\xB5\x2F\xFD" then rbxmBuffer:seek(12); dataChunk = zstd(rbxmBuffer:read(compressed))
            else dataChunk = lz4(rbxmBuffer:read(compressed + 12)) end
        end
        chunk.Data = Buffer(dataChunk, false); table.insert(chunkInfo[chunk.Header], chunk); last_chunk = chunk
    until last_chunk and last_chunk.Header == valid_end_chunk

    for _, chunk in ipairs(chunkInfo["SSTR"] or {}) do
        local buffer = chunk.Data
        if buffer:readNumber("<I4") == 0 then
            for i = 1, buffer:readNumber("<I4") do buffer:read(16); strings[i] = basicTypes.String(buffer) end
        end
    end

    for _, chunk in ipairs(chunkInfo["INST"] or {}) do
        local buffer = chunk.Data
        local classID = buffer:readNumber("<I4"); local className = basicTypes.String(buffer)
        if buffer:read() == "\1" then return sources, "Contains services" end
        local count = buffer:readNumber("<I4"); local refs = basicTypes.RefArray(buffer, count)
        classRefs[classID] = { Name = className, Sizeof = count, Refs = refs }
        for _, ref in ipairs(refs) do virtualInstances[ref] = { ClassId = classID, ClassName = className, Ref = ref, Properties = {}, Children = {} } end
    end

    for _, chunk in ipairs(chunkInfo["PROP"] or {}) do
        local buffer = chunk.Data
        local classID = buffer:readNumber("<I4"); local classref = classRefs[classID]
        if not classref then return sources, "Missing classref" end
        local refs = classref.Refs; local sizeof = classref.Sizeof; local name = basicTypes.String(buffer)
        if string.byte(buffer:read(1, false)) == 0x1E then buffer:seek(1) end
        local typeID = string.byte(buffer:read()); local props = {}
        if typeID == 0x01 or typeID == 0x1D then
            for i = 1, sizeof do props[i] = basicTypes.String(buffer) end
        elseif typeID == 0x02 then
            for i = 1, sizeof do props[i] = buffer:read() ~= string.char(0) end
        elseif typeID == 0x03 then props = basicTypes.Int32Array(buffer, sizeof)
        elseif typeID == 0x04 then props = basicTypes.RbxF32Array(buffer, sizeof)
        elseif typeID == 0x05 then
            for i = 1, sizeof do props[i] = basicTypes.Float64(buffer) end
        else
            for i = 1, sizeof do
                if typeID == 0x13 then props = basicTypes.RefArray(buffer, sizeof); break else buffer:read(4) end
            end
        end
        if name == "Source" or name == "ContentText" then
            for i, v in ipairs(refs) do
                if virtualInstances[v] and props[i] then virtualInstances[v].Properties[name] = props[i] end
            end
        end
    end

    local function addSourceAlias(key, src)
        if not key or key == "" or not src or type(src) ~= "string" or #src == 0 then return end
        local bucketKey = "__ALIAS__" .. key
        local bucket = sources[bucketKey]
        if type(bucket) ~= "table" then bucket = {}; sources[bucketKey] = bucket end
        table.insert(bucket, src)
    end

    local function buildSourceMap(node, path)
        local src = node.Properties["Source"] or node.Properties["ContentText"]
        if src and type(src) == "string" and #src > 0 then
            src = src:gsub(string.char(0) .. "*$", "")
            sources[path] = src
            local className = tostring(node.ClassName or "")
            local name = tostring(node.Properties["Name"] or "")
            if className ~= "" and name ~= "" then addSourceAlias(className .. ":" .. name, src) end
            if name ~= "" then addSourceAlias(name, src) end
        end
        for _, child in ipairs(node.Children or {}) do
            buildSourceMap(child, path .. "." .. child.ClassName .. ":" .. (child.Properties["Name"] or "unnamed"))
        end
    end

    for _, chunk in ipairs(chunkInfo["PRNT"] or {}) do
        local buffer = chunk.Data
        if buffer:read() ~= string.char(0) then return sources, "Invalid PRNT" end
        local count = buffer:readNumber("<I4")
        local child_refs = basicTypes.RefArray(buffer, count); local parent_refs = basicTypes.RefArray(buffer, count)
        for i = 1, count do
            local child = virtualInstances[child_refs[i]]; local parent = virtualInstances[parent_refs[i]]
            if child and parent then table.insert(parent.Children, child) end
        end
    end

    local roots = {}
    for _, inst in pairs(virtualInstances) do
        local hasParent = false
        for _, other in pairs(virtualInstances) do
            for _, child in ipairs(other.Children or {}) do if child.Ref == inst.Ref then hasParent = true; break end end
            if hasParent then break end
        end
        if not hasParent then table.insert(roots, inst) end
    end
    for _, root in ipairs(roots) do buildSourceMap(root, root.ClassName .. ":" .. (root.Properties["Name"] or "root")) end

    return sources, nil
end

-- ═══════════════════════════════════════════════════════════════════════
-- STUDIO LITE INTEGRATION
-- ═══════════════════════════════════════════════════════════════════════
local slFolder = ReplicatedStorage:FindFirstChild("StudioLiteFolder")
local serverFuncs = slFolder and slFolder:FindFirstChild("ServerFunctions")

local function triggerServerLoad(idStr)
    if not serverFuncs or not idStr or idStr == "" then return end
    local id = tostring(idStr):match("%d+")
    if id then pcall(function() serverFuncs:InvokeServer("LoadMeshToRuntimeMeshes", tonumber(id)) end) end
end

local SL_CACHE = {}

local function getInstancePath(obj)
    local parts, cur, guard = {}, obj, 0
    while cur and guard < 100 do
        guard = guard + 1
        table.insert(parts, 1, tostring(cur.ClassName) .. ":" .. tostring(cur.Name))
        cur = cur.Parent
    end
    return table.concat(parts, ".")
end

local function readLiveSource(scr)
    local source
    pcall(function() source = scr.Source end)
    if not source or #tostring(source) == 0 then pcall(function() source = scr.ContentText end) end
    if source and type(source) == "string" and #source > 0 then
        return source:gsub(string.char(0) .. "*$", "")
    end
    return nil
end

local function captureLiveSources(root)
    if not root then return 0 end
    local captured = 0
    local function capture(scr)
        if not scr or not scr:IsA("LuaSourceContainer") then return end
        local src = readLiveSource(scr)
        if src and #src > 0 then _G.LANGZ_RAW_SOURCES[scr] = src; captured = captured + 1 end
    end
    capture(root)
    for _, d in ipairs(root:GetDescendants()) do capture(d) end
    return captured
end

local function resolveSource(scr, sourceMap)
    if not scr then return nil end
    local live = readLiveSource(scr)
    if live then return live end
    if type(sourceMap) ~= "table" then return nil end

    local fullPath = getInstancePath(scr)
    local direct = sourceMap[fullPath]
    if type(direct) == "string" and #direct > 0 then return direct end

    for key, value in pairs(sourceMap) do
        if type(key) == "string" and key:sub(1, 9) ~= "__ALIAS__" and type(value) == "string" then
            if #key <= #fullPath and fullPath:sub(-#key) == key then return value end
        end
    end

    local bucket = sourceMap["__ALIAS__" .. tostring(scr.ClassName) .. ":" .. tostring(scr.Name)]
    if type(bucket) == "table" and #bucket == 1 then return bucket[1] end
    bucket = sourceMap["__ALIAS__" .. tostring(scr.Name)]
    if type(bucket) == "table" and #bucket == 1 then return bucket[1] end
    return nil
end

local function injectStudioLiteUI(scr, sourceMap)
    if not scr:IsA("LuaSourceContainer") then return false end
    local realSource = resolveSource(scr, sourceMap) or _G.LANGZ_RAW_SOURCES[scr]
    if not realSource or #realSource == 0 then realSource = "-- [LANGZ] Source tidak ditemukan." end
    realSource = realSource:gsub(string.char(0) .. "*$", "")
    _G.LANGZ_RAW_SOURCES[scr] = realSource

    local UI_TEXT = realSource
    if #UI_TEXT > 150000 then UI_TEXT = "-- [LANGZ Warning] Source terlalu panjang.\n\n" .. string.sub(UI_TEXT, 1, 150000) .. "\n\n... [TERPOTONG]" end

    local existingTB = scr:FindFirstChild("SL_CodeTextBox")
    if existingTB then
        existingTB.Text = UI_TEXT
        if scr.ClassName == "ModuleScript" then
            local ro = scr:FindFirstChild("SL_1ReadOnly")
            if ro then ro.ContentText = UI_TEXT; ro.Text = UI_TEXT end
        end
        return true
    end

    if not serverFuncs then return false end
    local map = { Script = "InsertScriptScript", LocalScript = "InsertLocalScriptLocalScript", ModuleScript = "InsertModuleScriptModuleScript" }
    local assetName = map[scr.ClassName]
    if not assetName then return false end

    if not SL_CACHE[assetName] then
        pcall(function()
            serverFuncs:InvokeServer("LoadAssetToPlayerGui", assetName)
            local guiF = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild(assetName, 3)
            if guiF then
                SL_CACHE[assetName] = {}
                for _, c in ipairs(guiF:GetChildren()) do table.insert(SL_CACHE[assetName], c:Clone()) end
                serverFuncs:InvokeServer("ClearAssetFromPlayerGui", assetName)
            end
        end)
    end
    if not SL_CACHE[assetName] then return false end

    local ok = pcall(function()
        for _, c in ipairs(SL_CACHE[assetName]) do c:Clone().Parent = scr end
        local tb = scr:FindFirstChild("SL_CodeTextBox")
        if tb then
            tb.Text = UI_TEXT
            if scr.ClassName == "ModuleScript" then
                local ro = scr:FindFirstChild("SL_1ReadOnly")
                if ro then ro.ContentText = UI_TEXT; ro.Text = UI_TEXT end
            end
        end
    end)
    return ok
end

local function injectAllScripts(root, sourceMap)
    if not root then return 0, 0 end
    local list = {}
    if root:IsA("LuaSourceContainer") then table.insert(list, root) end
    for _, d in ipairs(root:GetDescendants()) do if d:IsA("LuaSourceContainer") then table.insert(list, d) end end
    local okCount, failCount = 0, 0
    for _, scr in ipairs(list) do
        local ok, result = pcall(injectStudioLiteUI, scr, sourceMap)
        if ok and result then okCount = okCount + 1 else failCount = failCount + 1 end
        task.wait(0.02)
    end
    return okCount, failCount
end

local function ApplyStudioLiteProperties(obj)
    if not obj then return end
    pcall(function()
        if obj:IsA("BasePart") then
            local originalAnchor = obj.Anchored
            local originalCollide = obj.CanCollide
            obj.Anchored = true
            if obj:GetAttribute("SL_Anchored") == nil then obj:SetAttribute("SL_Anchored", originalAnchor) end
            if obj:GetAttribute("SL_CanCollide") == nil then obj:SetAttribute("SL_CanCollide", originalCollide) end
        end
    end)
    for _, child in ipairs(obj:GetChildren()) do ApplyStudioLiteProperties(child) end
end

local function LoadAssetsToSLServer(obj)
    local function scan(node)
        pcall(function()
            if node:IsA("MeshPart") then triggerServerLoad(node.MeshId); triggerServerLoad(node.TextureID)
            elseif node:IsA("Decal") or node:IsA("Texture") then triggerServerLoad(node.Texture)
            elseif node:IsA("SpecialMesh") then triggerServerLoad(node.MeshId); triggerServerLoad(node.TextureId)
            elseif node:IsA("Clothing") or node:IsA("ShirtGraphic") then triggerServerLoad(node.ClassName == "ShirtGraphic" and node.Graphic or node[node.ClassName.."Template"])
            elseif node:IsA("UnionOperation") or node:IsA("PartOperation") then triggerServerLoad(node.AssetId) end
        end)
        for _, child in ipairs(node:GetChildren()) do scan(child) end
    end
    scan(obj)
end

local SVC_MAP = { 
    Workspace = workspace, 
    ReplicatedStorage = ReplicatedStorage, 
    ReplicatedFirst = game:GetService("ReplicatedFirst"), 
    StarterGui = game:GetService("StarterGui"), 
    StarterPack = game:GetService("StarterPack"), 
    StarterPlayer = game:GetService("StarterPlayer"), 
    Lighting = game:GetService("Lighting"), 
    SoundService = game:GetService("SoundService"), 
    ServerScriptService = _G.sss or ReplicatedStorage, 
    ServerStorage = _G.ss or ReplicatedStorage, 
    Teams = ReplicatedStorage, 
    Chat = ReplicatedStorage 
}

local function insertObjects(objects, isRbxl, sourceMap)
    local count = 0
    for _, obj in ipairs(objects) do
        pcall(function()
            local target = (isRbxl and (SVC_MAP[obj.ClassName] or SVC_MAP[obj.Name])) or workspace
            if target == workspace and obj:IsA("Service") then target = ReplicatedStorage end

            if isRbxl and target ~= workspace then
                for _, ch in ipairs(obj:GetChildren()) do
                    pcall(function() 
                        ch.Parent = target; 
                        injectAllScripts(ch, sourceMap); 
                        ApplyStudioLiteProperties(ch); 
                        LoadAssetsToSLServer(ch); 
                        count = count + 1 
                    end)
                    task.wait(0.01)
                end
            else
                obj.Parent = target; 
                injectAllScripts(obj, sourceMap); 
                ApplyStudioLiteProperties(obj); 
                LoadAssetsToSLServer(obj); 
                count = count + 1
            end
        end)
    end
    return count
end

local function safeReadFile(p)
    if type(readfile) ~= "function" then return nil, "readfile tidak tersedia" end
    local ok, d = pcall(readfile, p)
    if ok and type(d) == "string" and #d > 0 then return d end
    return nil, "File tidak bisa dibaca: " .. tostring(p)
end

local function normalizeLocalPath(path)
    path = tostring(path or ""):gsub("^%s+", ""):gsub("%s+$", "")
    path = path:gsub('^file://', '')
    path = path:gsub('^[' .. string.char(34) .. "']", ""):gsub("[" .. string.char(34) .. "']$", "")
    return path
end

local function getLocalAsset(path)
    -- Executor Android biasanya memakai getcustomasset; beberapa memakai getsynasset.
    local providers = {
        type(getcustomasset) == "function" and getcustomasset or nil,
        type(getsynasset) == "function" and getsynasset or nil,
    }
    for _, provider in ipairs(providers) do
        local ok, asset = pcall(provider, path)
        if ok and type(asset) == "string" and asset ~= "" then
            return asset
        end
    end
    return nil
end

local function loadObjectsFromLocal(path)
    local assetUri = getLocalAsset(path)
    if not assetUri then return nil, "Executor tidak menyediakan getcustomasset/getsynasset" end

    local ok, objects = pcall(function()
        return game:GetObjects(assetUri)
    end)
    if ok and type(objects) == "table" and #objects > 0 then
        return objects
    end

    return nil, "getcustomasset berhasil, tetapi Roblox gagal membuka RBXM"
end

local function loadFile(fileInfo)
    local isRbxl = fileInfo.ftype == "RBXL"
    local path = normalizeLocalPath(fileInfo.path)
    if path == "" then return false, "Path file kosong" end

    local data, readErr = safeReadFile(path)
    if not data then return false, readErr end

    -- Validasi dasar supaya file yang dipilih memang RBXM/RBXMX.
    if not isRbxl then
        local header = data:sub(1, 8)
        if header ~= "<roblox!" then
            return false, "File bukan RBXM/RBXMX yang valid"
        end
    end

    local sourceMap = {}
    if not isRbxl then
        local ok, sources = pcall(parseRBXMForSources, data)
        if ok and type(sources) == "table" then sourceMap = sources end
    end

    -- Cara utama: ubah file lokal menjadi rbxasset:// lalu buka sebagai Objects.
    local objects, loadErr = loadObjectsFromLocal(path)
    if objects then
        for _, obj in ipairs(objects) do captureLiveSources(obj) end
        local count = insertObjects(objects, isRbxl, sourceMap)
        if count > 0 then
            return true, count .. " object(s) loaded"
        end
        return false, "File terbuka tetapi object tidak bisa dimasukkan ke Workspace"
    end

    -- Fallback untuk executor lama.
    local ok2, objects2 = pcall(function()
        return game:GetObjects("rbxasset://" .. path)
    end)
    if ok2 and type(objects2) == "table" and #objects2 > 0 then
        for _, obj in ipairs(objects2) do captureLiveSources(obj) end
        local count = insertObjects(objects2, isRbxl, sourceMap)
        if count > 0 then return true, count .. " object(s) loaded" end
    end

    return false, loadErr or "RBXM tidak bisa dibuka oleh executor ini"
end

-- ═══════════════════════════════════════════════════════════════════════
-- FILE SCANNER
-- ═══════════════════════════════════════════════════════════════════════
local function safeListFiles(p) if not listfiles then return nil end; local ok, f = pcall(listfiles, p); return ok and f or nil end
local function getFileName(p) return p:match("([^/]+)$") or p end
local function getFileType(n) 
    n = n:lower(); 
    if n:match("%.rbxl") or n:match("%.rbxlx") then return "RBXL" 
    elseif n:match("%.rbxm") or n:match("%.rbxmx") then return "RBXM" end; 
    return nil 
end
local function looksFolder(p) return not getFileName(p):match("%.[%a%d]+") end

local SCAN_PATHS = {
    "workspace", "Delta/workspace", "delta/workspace", "Android/Delta/workspace",
    "/sdcard/Delta/workspace", "/sdcard/Android/Delta/workspace",
    "/sdcard/Download", "/sdcard/Downloads",
    "/storage/emulated/0/Download", "/storage/emulated/0/Downloads",
    "/storage/emulated/0/Delta/workspace",
    "../workspace", ".", ""
}

local function scanDeep(folder, depth, results, seen)
    if depth > 4 or seen[folder] then return end
    seen[folder] = true
    local list = safeListFiles(folder)
    if not list then return end
    for _, path in ipairs(list) do
        local name = getFileName(path); local ftype = getFileType(name)
        if ftype and not seen[path] then
            seen[path] = true; table.insert(results, { name=name, path=path, ftype=ftype, folder=folder })
        elseif looksFolder(path) then scanDeep(path, depth+1, results, seen) end
    end
end

local function scanAll()
    local results, seen = {}, {}; 
    for _, p in ipairs(SCAN_PATHS) do 
        if safeListFiles(p) then scanDeep(p, 0, results, seen) end 
    end
    return results
end


-- TOOLBOX MODEL INSERT
local function extractAssetId(value)
    value=tostring(value or '')
    return tonumber(value:match('(%d+)'))
end
local function insertToolboxModel(value)
    local assetId=extractAssetId(value)
    if not assetId then return false,'Asset ID tidak valid' end
    local inserted
    local ok,result=pcall(function() return InsertService:LoadAsset(assetId) end)
    if ok and result then inserted=result end
    if not inserted and game.GetObjects then
        local ok2,result2=pcall(function() return game:GetObjects('rbxassetid://'..assetId) end)
        if ok2 and result2 and #result2>0 then
            inserted=Instance.new('Folder'); inserted.Name='Toolbox_'..assetId; inserted.Parent=workspace
            for _,obj in ipairs(result2) do obj.Parent=inserted end
        end
    end
    if not inserted then return false,'Model gagal dimuat. Pastikan Asset ID model publik/diizinkan.' end
    if inserted.Parent==nil then inserted.Parent=workspace end

    local captured = captureLiveSources(inserted)
    local injected = injectAllScripts(inserted,{})
    ApplyStudioLiteProperties(inserted)
    LoadAssetsToSLServer(inserted)

    local scriptCount = 0
    if inserted:IsA("LuaSourceContainer") then scriptCount = 1 end
    for _, d in ipairs(inserted:GetDescendants()) do if d:IsA("LuaSourceContainer") then scriptCount = scriptCount + 1 end end

    if scriptCount > 0 and injected == 0 then
        return true, tostring(inserted.Name) .. " (model masuk, tetapi script belum berhasil dipasang)"
    end
    return true,tostring(inserted.Name) .. " (script " .. tostring(injected) .. "/" .. tostring(scriptCount) .. ", source " .. tostring(captured) .. ")"
end

-- AUDIO / MUSIC INSERT
-- Inserted music is always placed in Workspace.NANG_MUSIC so it is visible in
-- Studio Lite Explorer/Workspace.
local function getMusicFolder()
    local folder = workspace:FindFirstChild("NANG_MUSIC")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "NANG_MUSIC"
        folder.Parent = workspace
    end
    return folder
end

local function insertToolboxAudio(value, assetName)
    local assetId = extractAssetId(value)
    if not assetId then return false, "Audio ID tidak valid" end

    local folder = getMusicFolder()
    local finalName = tostring(assetName or ("Music_" .. assetId))

    -- First try to load the actual Roblox Sound asset.
    local ok, result = pcall(function()
        return InsertService:LoadAsset(assetId)
    end)
    if ok and result then
        local sound = result:IsA("Sound") and result or result:FindFirstChildWhichIsA("Sound", true)
        if sound then
            sound.Name = finalName
            sound.Parent = folder
            if result ~= sound then pcall(function() result:Destroy() end) end
            return true, sound.Name .. " → Workspace.NANG_MUSIC"
        end
        pcall(function() result:Destroy() end)
    end

    -- Second Roblox loading path.
    if game.GetObjects then
        local ok2, objects = pcall(function()
            return game:GetObjects("rbxassetid://" .. tostring(assetId))
        end)
        if ok2 and type(objects) == "table" then
            for _, obj in ipairs(objects) do
                local sound = obj:IsA("Sound") and obj or obj:FindFirstChildWhichIsA("Sound", true)
                if sound then
                    sound.Name = finalName
                    sound.Parent = folder
                    if obj ~= sound then pcall(function() obj:Destroy() end) end
                    return true, sound.Name .. " → Workspace.NANG_MUSIC"
                end
            end
        end
    end

    -- Always create a visible Sound object as fallback. Playback is subject to
    -- Roblox audio permissions, but the object itself will be in Workspace.
    local sound = Instance.new("Sound")
    sound.Name = finalName
    sound.SoundId = "rbxassetid://" .. tostring(assetId)
    sound.Volume = 0.5
    sound.Archivable = true
    sound.Parent = folder
    return true, sound.Name .. " → Workspace.NANG_MUSIC"
end

local function insertToolboxAsset(value, kind, assetName)
    kind = tostring(kind or "MODEL"):upper()
    if kind == "AUDIO" then
        return insertToolboxAudio(value, assetName)
    end
    return insertToolboxModel(value)
end


-- ═══════════════════════════════════════════════════════════════════════
-- CREATOR STORE MODEL SEARCH
-- ═══════════════════════════════════════════════════════════════════════
local Scroll, EmptyFrame, notify
local SearchScroll, SearchEmptyFrame
local CREATOR_STORE_SEARCH = {
    ["MODEL"] = {
        "https://apis.roblox.com/toolbox-service/v1/marketplace/10",
        "https://apis.roproxy.com/toolbox-service/v1/marketplace/10",
        "https://apis.rotunnel.com/toolbox-service/v1/marketplace/10"
    },
    ["DECAL"] = {
        "https://apis.roblox.com/toolbox-service/v1/marketplace/13",
        "https://apis.roproxy.com/toolbox-service/v1/marketplace/13",
        "https://apis.rotunnel.com/toolbox-service/v1/marketplace/13"
    },
    ["AUDIO"] = {
        "https://apis.roblox.com/toolbox-service/v1/marketplace/3",
        "https://apis.roproxy.com/toolbox-service/v1/marketplace/3",
        "https://apis.rotunnel.com/toolbox-service/v1/marketplace/3"
    }
}

local function searchCreatorModels(keyword, pageNumber, assetType)
    keyword = tostring(keyword or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if keyword == "" then return false, "Masukkan kata kunci yang ingin dicari." end
    assetType = tostring(assetType or "MODEL"):upper()
    if not CREATOR_STORE_SEARCH[assetType] then assetType = "MODEL" end
    pageNumber = math.max(0, tonumber(pageNumber) or 0)

    local query = "?limit=100&pageNumber=" .. tostring(pageNumber)
        .. "&keyword=" .. HttpService:UrlEncode(keyword)
        .. "&includeOnlyVerifiedCreators=false"

    local lastError = "Tidak ada respons dari Creator Store."
    for _, base in ipairs(CREATOR_STORE_SEARCH[assetType]) do
        local body, status = httpRequest(base .. query, "GET")
        if body and (not status or (status >= 200 and status < 300)) then
            local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
            if ok and type(data) == "table" then
                local raw = data.data or data.items or data.results
                if type(raw) == "table" then
                    local results = {}
                    for _, item in ipairs(raw) do
                        local id = tonumber(item.id or item.assetId or item.AssetId or (item.asset and item.asset.id))
                        if id then
                            local creator = item.creatorName or item.CreatorName or item.creator or "Creator Store"
                            if type(creator) == "table" then
                                creator = creator.name or creator.Name or creator.username or "Creator Store"
                            end
                            table.insert(results, {
                                id = id,
                                name = tostring(item.name or item.Name or item.title or ("Asset " .. id)),
                                creator = tostring(creator),
                                kind = assetType
                            })
                        end
                    end
                    return true, results, data.nextPageCursor or data.nextPageToken
                end
                lastError = "Respons Creator Store tidak berisi daftar asset."
            else
                lastError = "JSON Creator Store tidak valid."
            end
        elseif status then
            lastError = "Creator Store HTTP " .. tostring(status)
        end
    end
    return false, lastError
end

local function clearScrollCards()
    if SearchScroll then
        for _, c in ipairs(SearchScroll:GetChildren()) do
            if c:IsA("Frame") and c ~= SearchEmptyFrame then c:Destroy() end
        end
    end
end

local function buildModelResultCard(info)
    if not SearchScroll then return end
    SearchEmptyFrame.Visible = false

    local card = Instance.new("Frame", SearchScroll)
    card.Size = UDim2.new(0, 150, 0, 178)
    card.BackgroundColor3 = Color3.fromRGB(8,22,8)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", card)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(58,58,58)

    local thumb = Instance.new("ImageLabel", card)
    thumb.Size = UDim2.new(1, -12, 0, 92)
    thumb.Position = UDim2.new(0, 6, 0, 6)
    thumb.BackgroundColor3 = Color3.fromRGB(15,15,15)
    thumb.BorderSizePixel = 0
    thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(info.id) .. "&w=420&h=420"
    thumb.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)

    local badge = Instance.new("TextLabel", card)
    badge.Size = UDim2.new(0, 50, 0, 18)
    badge.Position = UDim2.new(1, -56, 0, 12)
    badge.BackgroundColor3 = Color3.fromRGB(36,120,36)
    badge.Text = tostring(info.kind or "MODEL")
    badge.TextColor3 = Color3.new(1,1,1)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 7
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)

    local name = Instance.new("TextLabel", card)
    name.Size = UDim2.new(1, -12, 0, 24)
    name.Position = UDim2.new(0, 6, 0, 102)
    name.BackgroundTransparency = 1
    name.Text = tostring(info.name)
    name.TextColor3 = Color3.fromRGB(245,245,245)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 10
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd

    local creator = Instance.new("TextLabel", card)
    creator.Size = UDim2.new(1, -12, 0, 22)
    creator.Position = UDim2.new(0, 6, 0, 126)
    creator.BackgroundTransparency = 1
    creator.Text = "by " .. tostring(info.creator) .. "\nID: " .. tostring(info.id)
    creator.TextColor3 = Color3.fromRGB(145,145,145)
    creator.Font = Enum.Font.Gotham
    creator.TextSize = 7
    creator.TextXAlignment = Enum.TextXAlignment.Left

    local insert = Instance.new("TextButton", card)
    insert.Size = UDim2.new(1, -12, 0, 26)
    insert.Position = UDim2.new(0, 6, 1, -32)
    insert.BackgroundColor3 = Color3.fromRGB(36,130,36)
    insert.BorderSizePixel = 0
    insert.Text = "INSERT"
    insert.TextColor3 = Color3.new(1,1,1)
    insert.Font = Enum.Font.GothamBold
    insert.TextSize = 9
    Instance.new("UICorner", insert).CornerRadius = UDim.new(0, 6)

    insert.MouseButton1Click:Connect(function()
        if insert.Text == "LOAD..." then return end
        insert.Text = "LOAD..."
        task.spawn(function()
            local ok, msg = insertToolboxAsset(tostring(info.id), info.kind, info.name)
            if ok then
                insert.Text = "DONE"
                insert.BackgroundColor3 = Color3.fromRGB(50,160,50)
                if tostring(info.kind):upper() == "AUDIO" then
                    notify("Music", tostring(info.name) .. " berhasil ditambahkan ke SoundService.", Color3.fromRGB(80,200,80))
                else
                    notify("Toolbox", tostring(info.name) .. " berhasil diinsert.", Color3.fromRGB(80,200,80))
                end
            else
                insert.Text = "FAIL"
                insert.BackgroundColor3 = Color3.fromRGB(24,78,24)
                notify("Insert Gagal", tostring(msg), Color3.fromRGB(122,122,122))
            end
            task.wait(1.2)
            insert.Text = "INSERT"
            insert.BackgroundColor3 = Color3.fromRGB(36,130,36)
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- DESTROY OLD UI
-- ═══════════════════════════════════════════════════════════════════════
if CoreDest:FindFirstChild("LANGZImporterUI") then CoreDest:FindFirstChild("LANGZImporterUI"):Destroy() end
if CoreDest:FindFirstChild("LANGZImporterUI") then CoreDest:FindFirstChild("LANGZImporterUI"):Destroy() end

local UI = Instance.new("ScreenGui", CoreDest)
UI.Name = "LANGZImporterUI"; UI.ResetOnSpawn = false; UI.DisplayOrder = 100; UI.IgnoreGuiInset = true

-- Modern dark atmosphere with purple accent.
local HackerAtmosphere = Instance.new("Frame", UI)
HackerAtmosphere.Name = "HackerAtmosphere"
HackerAtmosphere.Size = UDim2.new(1, 0, 1, 0)
HackerAtmosphere.Position = UDim2.new(0, 0, 0, 0)
HackerAtmosphere.BackgroundColor3 = Color3.fromRGB(11,11,11)
HackerAtmosphere.BackgroundTransparency = 0.84
HackerAtmosphere.BorderSizePixel = 0
HackerAtmosphere.ZIndex = 0
HackerAtmosphere.Active = false

-- Table untuk menampung UIGradient yang akan dianimasikan secara real-time
local AnimatedGradients = {}

local function registerGradientAnimation(gradient, speed, mode)
    table.insert(AnimatedGradients, {
        Gradient = gradient,
        Speed = speed or 60,
        Mode = mode or "rotate"
    })
end

-- ═══════════════════════════════════════════════════════════════════════
-- LOADING SCREEN — NANG RBXM ELEGANT
-- Only this loading screen is used. The old Execute Fixed boot screen is removed.
local LoadingScreen = Instance.new("Frame", UI)
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.BackgroundColor3 = Color3.fromRGB(8,8,8)
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex = 999

local Dim = Instance.new("Frame", LoadingScreen)
Dim.Size = UDim2.new(1, 0, 1, 0)
Dim.BackgroundColor3 = Color3.fromRGB(0,0,0)
Dim.BackgroundTransparency = 0.18
Dim.BorderSizePixel = 0
Dim.ZIndex = 999

local Card = Instance.new("Frame", LoadingScreen)
Card.Name = "BootCard"
Card.AnchorPoint = Vector2.new(0.5, 0.5)
Card.Position = UDim2.new(0.5, 0, 0.5, 0)
Card.Size = UDim2.new(0, 360, 0, 190)
Card.BackgroundColor3 = Color3.fromRGB(18,18,18)
Card.BorderSizePixel = 0
Card.ZIndex = 1000
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

local CardStroke = Instance.new("UIStroke", Card)
CardStroke.Thickness = 1
CardStroke.Transparency = 0.25
CardStroke.Color = Color3.fromRGB(34,139,34)

local Accent = Instance.new("Frame", Card)
Accent.Size = UDim2.new(0, 4, 1, -28)
Accent.Position = UDim2.new(0, 0, 0, 14)
Accent.BackgroundColor3 = Color3.fromRGB(34,139,34)
Accent.BorderSizePixel = 0
Accent.ZIndex = 1001
Instance.new("UICorner", Accent).CornerRadius = UDim.new(1, 0)

local Brand = Instance.new("TextLabel", Card)
Brand.Size = UDim2.new(1, -48, 0, 36)
Brand.Position = UDim2.new(0, 24, 0, 22)
Brand.BackgroundTransparency = 1
Brand.Text = "NANG RBXM"
Brand.TextColor3 = Color3.fromRGB(80,200,80)
Brand.Font = Enum.Font.GothamBold
Brand.TextSize = 25
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.ZIndex = 1001

local Sub = Instance.new("TextLabel", Card)
Sub.Size = UDim2.new(1, -48, 0, 20)
Sub.Position = UDim2.new(0, 24, 0, 58)
Sub.BackgroundTransparency = 1
Sub.Text = "Preparing your workspace"
Sub.TextColor3 = Color3.fromRGB(146,146,146)
Sub.Font = Enum.Font.Gotham
Sub.TextSize = 12
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.ZIndex = 1001

local Status = Instance.new("TextLabel", Card)
Status.Size = UDim2.new(1, -48, 0, 18)
Status.Position = UDim2.new(0, 24, 0, 96)
Status.BackgroundTransparency = 1
Status.Text = "Starting..."
Status.TextColor3 = Color3.fromRGB(215,215,215)
Status.Font = Enum.Font.GothamMedium
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.ZIndex = 1001

local Track = Instance.new("Frame", Card)
Track.Size = UDim2.new(1, -48, 0, 6)
Track.Position = UDim2.new(0, 24, 0, 123)
Track.BackgroundColor3 = Color3.fromRGB(38,38,38)
Track.BorderSizePixel = 0
Track.ZIndex = 1001
Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

local Progress = Instance.new("Frame", Track)
Progress.Size = UDim2.new(0, 0, 1, 0)
Progress.BackgroundColor3 = Color3.fromRGB(34,139,34)
Progress.BorderSizePixel = 0
Progress.ZIndex = 1002
Instance.new("UICorner", Progress).CornerRadius = UDim.new(1, 0)

local Footer = Instance.new("TextLabel", Card)
Footer.Size = UDim2.new(1, -48, 0, 18)
Footer.Position = UDim2.new(0, 24, 0, 146)
Footer.BackgroundTransparency = 1
Footer.Text = "NANG RBXM"
Footer.TextColor3 = Color3.fromRGB(30,115,30)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.ZIndex = 1001

local loadingActive = true
local loadSteps = {
    {"Starting...", 0.18},
    {"Loading interface...", 0.45},
    {"Preparing Toolbox...", 0.72},
    {"Ready", 1},
}

task.spawn(function()
    for _, step in ipairs(loadSteps) do
        if not loadingActive or not LoadingScreen.Parent then return end
        Status.Text = step[1]
        TweenService:Create(
            Progress,
            TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(step[2], 0, 1, 0)}
        ):Play()
        task.wait(0.34)
    end

    task.wait(0.35)
    if not LoadingScreen.Parent then return end

    loadingActive = false
    local fadeInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Card, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(Dim, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(CardStroke, fadeInfo, {Transparency = 1}):Play()

    for _, obj in ipairs(Card:GetDescendants()) do
        if obj:IsA("TextLabel") then
            TweenService:Create(obj, fadeInfo, {TextTransparency = 1}):Play()
        elseif obj:IsA("Frame") and obj ~= Card then
            TweenService:Create(obj, fadeInfo, {BackgroundTransparency = 1}):Play()
        end
    end

    task.wait(0.32)
    if LoadingScreen.Parent then LoadingScreen:Destroy() end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- RenderStepped Animation Engine (60 FPS Smooth Movement)
-- ═══════════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function(deltaTime)
    for _, anim in ipairs(AnimatedGradients) do
        if anim.Gradient and anim.Gradient.Parent then
            if anim.Mode == "rotate" then
                anim.Gradient.Rotation = (anim.Gradient.Rotation + (anim.Speed * deltaTime)) % 360
            elseif anim.Mode == "shift" then
                local currentX = anim.Gradient.Offset.X
                local newX = currentX + (anim.Speed * deltaTime)
                if newX > 1 then newX = -1 end
                anim.Gradient.Offset = Vector2.new(newX, anim.Gradient.Offset.Y)
            end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- FLOATING TOGGLE BUTTON WITH VECTOR CHEVRON ICON
-- ═══════════════════════════════════════════════════════════════════════
local ToggleFrame = Instance.new("Frame", UI)
ToggleFrame.Name = "ToggleFrame"
ToggleFrame.Size = UDim2.new(0, 36, 0, 36)
-- Keep the only toggle directly below the Roblox menu.
ToggleFrame.Position = UDim2.new(0, 8, 0, 48)
ToggleFrame.BackgroundColor3 = Color3.fromRGB(16,16,16)
ToggleFrame.BackgroundTransparency = 0.08
ToggleFrame.BorderSizePixel = 0
ToggleFrame.Active = true

local ToggleCorner = Instance.new("UICorner", ToggleFrame)
ToggleCorner.CornerRadius = UDim.new(0, 10)

local ToggleGrad = Instance.new("UIGradient", ToggleFrame)
ToggleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10,28,10)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30,100,30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(11,11,11))
})
ToggleGrad.Rotation = 45
registerGradientAnimation(ToggleGrad, 40, "rotate")

local ToggleStroke = Instance.new("UIStroke", ToggleFrame)
ToggleStroke.Thickness = 1.2
ToggleStroke.Color = Color3.fromRGB(60,170,60)
ToggleStroke.Transparency = 0.18

local ToggleIcon = Instance.new("ImageLabel", ToggleFrame)
ToggleIcon.Size = UDim2.new(0, 20, 0, 20)
ToggleIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Image = ICONS.CHEVRON_RIGHT
ToggleIcon.ImageColor3 = Color3.fromRGB(239,239,239)

local ToggleBtn = Instance.new("TextButton", ToggleFrame)
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Text = ""

-- Dragging System Toggle Button
local tDragToggle, tDragStart, tStartPos
ToggleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragToggle = true; tDragStart = input.Position; tStartPos = ToggleFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if tDragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tDragStart
        ToggleFrame.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        tDragToggle = false
    end
end)

-- MAIN CONTAINER
local Main = Instance.new("Frame", UI)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 780, 0, 500)
Main.Position = UDim2.new(0.5, -390, 0.5, -250)
Main.BackgroundColor3 = Color3.fromRGB(8,22,8)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(20,60,20)

local UIScale = Instance.new("UIScale", Main)
local function fitUI()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local v = cam.ViewportSize
    UIScale.Scale = math.clamp(math.min(v.X / 820, v.Y / 540), 0.55, 1)
end
fitUI()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitUI) end

-- HEADER
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundColor3 = Color3.fromRGB(10,28,10)
Header.BorderSizePixel = 0
local HeaderStroke = Instance.new("UIStroke", Header)
HeaderStroke.Color = Color3.fromRGB(16,46,16)

local Brand = Instance.new("TextLabel", Header)
Brand.Size = UDim2.new(0, 220, 0, 28)
Brand.Position = UDim2.new(0, 22, 0, 12)
Brand.BackgroundTransparency = 1
Brand.Text = "NANG"
Brand.TextColor3 = Color3.fromRGB(226,226,226)
Brand.Font = Enum.Font.GothamBold
Brand.TextSize = 20
Brand.TextXAlignment = Enum.TextXAlignment.Left
local Brand2 = Instance.new("TextLabel", Header)
Brand2.Size = UDim2.new(0, 180, 0, 28)
Brand2.Position = UDim2.new(0, 74, 0, 12)
Brand2.BackgroundTransparency = 1
Brand2.Text = "RBXM"
Brand2.TextColor3 = Color3.fromRGB(135,135,135)
Brand2.Font = Enum.Font.GothamBold
Brand2.TextSize = 20
Brand2.TextXAlignment = Enum.TextXAlignment.Left
local Version = Instance.new("TextLabel", Header)
Version.Size = UDim2.new(0, 50, 0, 20)
Version.Position = UDim2.new(0, 132, 0, 16)
Version.BackgroundColor3 = Color3.fromRGB(16,46,16)
Version.Text = "v64.0"
Version.TextColor3 = Color3.fromRGB(85,205,85)
Version.Font = Enum.Font.Gotham
Version.TextSize = 8
Instance.new("UICorner", Version).CornerRadius = UDim.new(0,5)

-- CREATOR / PURCHASE INFO — always visible at the top of the UI.
local CreatorInfo = Instance.new("TextLabel", Header)
CreatorInfo.Size = UDim2.new(0, 275, 0, 48)
CreatorInfo.Position = UDim2.new(0, 205, 0, 7)
CreatorInfo.BackgroundColor3 = Color3.fromRGB(10,28,10)
CreatorInfo.BackgroundTransparency = 0
CreatorInfo.Text = "MADE BY: NANG   |   ROBLOX ID: 8236629801\nBUY SCRIPT: 081252425581"
CreatorInfo.TextColor3 = Color3.fromRGB(211,211,211)
CreatorInfo.Font = Enum.Font.GothamBold
CreatorInfo.TextSize = 10
CreatorInfo.TextXAlignment = Enum.TextXAlignment.Center
CreatorInfo.TextYAlignment = Enum.TextYAlignment.Center
CreatorInfo.ZIndex = 20
Instance.new("UICorner", CreatorInfo).CornerRadius = UDim.new(0, 8)
local CreatorStroke = Instance.new("UIStroke", CreatorInfo)
CreatorStroke.Color = Color3.fromRGB(30,100,30)
CreatorStroke.Thickness = 1

local TitleIcon = Instance.new("ImageLabel", Header)
TitleIcon.Size = UDim2.new(0, 24, 0, 24)
TitleIcon.Position = UDim2.new(0, 490, 0, 19)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = ICONS.PACKAGE
TitleIcon.ImageColor3 = Color3.fromRGB(40,160,40)
local TitleText = Instance.new("TextLabel", Header)
TitleText.Size = UDim2.new(0, 180, 0, 24)
TitleText.Position = UDim2.new(0, 520, 0, 8)
TitleText.BackgroundTransparency = 1
TitleText.Text = "TOOLBOX"
TitleText.TextColor3 = Color3.fromRGB(245,245,245)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(0, 180, 0, 16)
Subtitle.Position = UDim2.new(0, 520, 0, 32)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Cari & import asset dari Roblox Creator Store"
Subtitle.TextColor3 = Color3.fromRGB(130,130,130)
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 44, 0, 40)
CloseBtn.Position = UDim2.new(1, -54, 0, 15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(18,55,18)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(225,225,225)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
local CloseClick = CloseBtn
local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 44, 0, 40)
MinBtn.Position = UDim2.new(1, -104, 0, 15)
MinBtn.BackgroundColor3 = Color3.fromRGB(16,44,16)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(230,230,230)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
local MinClick = MinBtn

-- DRAG HEADER
local dragToggle, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true; dragStart = input.Position; startPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end
end)

local function toggleMain()
    Main.Visible = not Main.Visible
    ToggleIcon.Image = Main.Visible and ICONS.CHEVRON_RIGHT or ICONS.CHEVRON_LEFT
end
ToggleBtn.MouseButton1Click:Connect(toggleMain)

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, -62)
Sidebar.Position = UDim2.new(0, 0, 0, 62)
Sidebar.BackgroundColor3 = Color3.fromRGB(10,28,10)
Sidebar.BorderSizePixel = 0
local SideTitle = Instance.new("TextLabel", Sidebar)
SideTitle.Size = UDim2.new(1, -24, 0, 70)
SideTitle.Position = UDim2.new(0, 12, 0, 8)
SideTitle.BackgroundTransparency = 1
local function getWhitelistGreeting()
    local playerName = tostring(LocalPlayer.DisplayName or LocalPlayer.Name or "Nang")

    -- Nama custom opsional berdasarkan UserId whitelist.
    -- Jika ID belum diberi nama custom, script otomatis memakai DisplayName Roblox.
    local WHITELIST_NAMES = {
        -- [8236629801] = "Nang",
        -- [10370966620] = "Nama Teman",
        -- [8153244285] = "Nama Lain",
        -- [9218615280] = "Nama Lain",
    }

    local customName = WHITELIST_NAMES[LocalPlayer.UserId]
    if customName and customName ~= "" then
        playerName = customName
    end

    -- Pastikan ID yang tampil memang berasal dari user yang lolos whitelist.
    return "Hello,\n" .. playerName .. " 👑"
end

SideTitle.Text = getWhitelistGreeting()
SideTitle.TextColor3 = Color3.fromRGB(216,216,216)
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextSize = 12
SideTitle.TextXAlignment = Enum.TextXAlignment.Center
SideTitle.TextYAlignment = Enum.TextYAlignment.Center

local sideItems = {"⌂  DASHBOARD", "▣  TOOLBOX • FREE", "▤  RBXM • FULL", "▣  RBXMX • FULL", "⚙  SETTINGS", "ⓘ  CREDITS"}
local sideButtons = {}
for i, text in ipairs(sideItems) do
    local b = Instance.new("TextButton", Sidebar)
    b.Size = UDim2.new(1, -16, 0, 36)
    b.Position = UDim2.new(0, 8, 0, 82 + (i-1)*39)
    b.BackgroundColor3 = (i == 2) and Color3.fromRGB(18,52,18) or Color3.fromRGB(10,28,10)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = (i == 2) and Color3.fromRGB(65,175,65) or Color3.fromRGB(186,186,186)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    sideButtons[i] = b
end
-- SIDEBAR NAVIGATION: setiap menu benar-benar berpindah ke fitur yang terlihat.
local ActivePage = "TOOLBOX"
local function setSideActive(index)
    for i, btn in ipairs(sideButtons) do
        btn.BackgroundColor3 = (i == index) and Color3.fromRGB(18,52,18) or Color3.fromRGB(10,28,10)
        btn.TextColor3 = (i == index) and Color3.fromRGB(65,175,65) or Color3.fromRGB(186,186,186)
    end
end

local StatusCard = Instance.new("Frame", Sidebar)
StatusCard.Size = UDim2.new(1, -24, 0, 80)
StatusCard.Position = UDim2.new(0, 12, 1, -94)
StatusCard.BackgroundColor3 = Color3.fromRGB(10,28,10)
StatusCard.BorderSizePixel = 0
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 10)
local Status = Instance.new("TextLabel", StatusCard)
Status.Size = UDim2.new(1, -18, 1, -12)
Status.Position = UDim2.new(0, 9, 0, 6)
Status.BackgroundTransparency = 1
Status.Text = "●  STATUS\n   WHITELIST ACCESS\n   ALL FEATURES READY"
Status.TextColor3 = Color3.fromRGB(95,185,95)
Status.Font = Enum.Font.GothamBold
Status.TextSize = 9
Status.TextXAlignment = Enum.TextXAlignment.Left

-- MAIN CONTENT
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -340, 1, -72)
Content.Position = UDim2.new(0, 160, 0, 70)
Content.BackgroundTransparency = 1

local SearchRow = Instance.new("Frame", Content)
SearchRow.Size = UDim2.new(1, 0, 0, 48)
SearchRow.BackgroundTransparency = 1

local SearchModelBox = Instance.new("TextBox", SearchRow)
SearchModelBox.Size = UDim2.new(1, -96, 0, 40)
SearchModelBox.Position = UDim2.new(0, 0, 0, 4)
SearchModelBox.BackgroundColor3 = Color3.fromRGB(10,30,10)
SearchModelBox.BorderSizePixel = 0
SearchModelBox.ClearTextOnFocus = false
SearchModelBox.PlaceholderText = "🔎  Cari di Creator Store..."
SearchModelBox.Text = ""
SearchModelBox.TextColor3 = Color3.fromRGB(240,240,240)
SearchModelBox.PlaceholderColor3 = Color3.fromRGB(120,120,120)
SearchModelBox.Font = Enum.Font.Gotham
SearchModelBox.TextSize = 11
Instance.new("UICorner", SearchModelBox).CornerRadius = UDim.new(0, 8)
local SearchModelBtn = Instance.new("TextButton", SearchRow)
SearchModelBtn.Size = UDim2.new(0, 86, 0, 40)
SearchModelBtn.Position = UDim2.new(1, -86, 0, 4)
SearchModelBtn.BackgroundColor3 = Color3.fromRGB(30,110,30)
SearchModelBtn.BorderSizePixel = 0
SearchModelBtn.Text = "SEARCH"
SearchModelBtn.TextColor3 = Color3.new(1,1,1)
SearchModelBtn.Font = Enum.Font.GothamBold
SearchModelBtn.TextSize = 10
Instance.new("UICorner", SearchModelBtn).CornerRadius = UDim.new(0, 8)

local TypeTabs = Instance.new("Frame", Content)
TypeTabs.Size = UDim2.new(1, 0, 0, 42)
TypeTabs.Position = UDim2.new(0, 0, 0, 52)
TypeTabs.BackgroundTransparency = 1
local SearchType = "MODEL"
local typeButtons = {}
for i, kind in ipairs({"MODEL", "DECAL", "AUDIO"}) do
    local b = Instance.new("TextButton", TypeTabs)
    b.Size = UDim2.new(0, 105, 0, 34)
    b.Position = UDim2.new(0, (i-1)*112, 0, 3)
    b.BackgroundColor3 = (i == 1) and Color3.fromRGB(40,160,40) or Color3.fromRGB(10,28,10)
    b.Text = kind
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 9
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    typeButtons[kind] = b
    b.MouseButton1Click:Connect(function()
        SearchType = kind
        for k, btn in pairs(typeButtons) do
            btn.BackgroundColor3 = (k == SearchType) and Color3.fromRGB(40,160,40) or Color3.fromRGB(10,28,10)
        end
    end)
end

local SearchHead = Instance.new("TextLabel", Content)
SearchHead.Size = UDim2.new(1, 0, 0, 28)
SearchHead.Position = UDim2.new(0, 0, 0, 98)
SearchHead.BackgroundColor3 = Color3.fromRGB(10,30,10)
SearchHead.Text = "  ⚙  HASIL PENCARIAN"
SearchHead.TextColor3 = Color3.fromRGB(235,235,235)
SearchHead.Font = Enum.Font.GothamBold
SearchHead.TextSize = 10
SearchHead.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", SearchHead).CornerRadius = UDim.new(0, 7)

SearchScroll = Instance.new("ScrollingFrame", Content)
SearchScroll.Size = UDim2.new(1, 0, 1, -132)
SearchScroll.Position = UDim2.new(0, 0, 0, 132)
SearchScroll.BackgroundTransparency = 1
SearchScroll.BorderSizePixel = 0
SearchScroll.ScrollBarThickness = 4
SearchScroll.ScrollBarImageColor3 = Color3.fromRGB(30,110,30)
SearchScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local SearchGrid = Instance.new("UIGridLayout", SearchScroll)
SearchGrid.CellSize = UDim2.new(0, 150, 0, 178)
SearchGrid.CellPadding = UDim2.new(0, 10, 0, 10)
SearchGrid.SortOrder = Enum.SortOrder.LayoutOrder

SearchEmptyFrame = Instance.new("Frame", SearchScroll)
SearchEmptyFrame.Size = UDim2.new(0, 470, 0, 180)
SearchEmptyFrame.BackgroundTransparency = 1
local SearchEmptyLabel = Instance.new("TextLabel", SearchEmptyFrame)
SearchEmptyLabel.Size = UDim2.new(1, 0, 1, 0)
SearchEmptyLabel.BackgroundTransparency = 1
SearchEmptyLabel.Text = "Cari asset dari Creator Store\nHasil akan muncul di sini."
SearchEmptyLabel.TextColor3 = Color3.fromRGB(110,110,110)
SearchEmptyLabel.Font = Enum.Font.Gotham
SearchEmptyLabel.TextSize = 11
SearchEmptyLabel.TextWrapped = true

-- RIGHT QUICK IMPORT
local Right = Instance.new("Frame", Main)
Right.Size = UDim2.new(0, 170, 1, -72)
Right.Position = UDim2.new(1, -180, 0, 70)
Right.BackgroundColor3 = Color3.fromRGB(10,28,10)
Right.BorderSizePixel = 0
Instance.new("UICorner", Right).CornerRadius = UDim.new(0, 12)
local QuickTitle = Instance.new("TextLabel", Right)
QuickTitle.Size = UDim2.new(1, -20, 0, 28)
QuickTitle.Position = UDim2.new(0, 10, 0, 12)
QuickTitle.BackgroundTransparency = 1
QuickTitle.Text = "⚡ QUICK IMPORT"
QuickTitle.TextColor3 = Color3.fromRGB(100,200,100)
QuickTitle.Font = Enum.Font.GothamBold
QuickTitle.TextSize = 12
QuickTitle.TextXAlignment = Enum.TextXAlignment.Left
local QuickHint = Instance.new("TextLabel", Right)
QuickHint.Size = UDim2.new(1, -20, 0, 42)
QuickHint.Position = UDim2.new(0, 10, 0, 42)
QuickHint.BackgroundTransparency = 1
QuickHint.Text = "Masukkan Asset ID atau URL langsung untuk import cepat."
QuickHint.TextColor3 = Color3.fromRGB(150,150,150)
QuickHint.Font = Enum.Font.Gotham
QuickHint.TextSize = 8
QuickHint.TextWrapped = true
QuickHint.TextXAlignment = Enum.TextXAlignment.Left

local ToolboxBox = Instance.new("TextBox", Right)
ToolboxBox.Size = UDim2.new(1, -20, 0, 36)
ToolboxBox.Position = UDim2.new(0, 10, 0, 88)
ToolboxBox.BackgroundColor3 = Color3.fromRGB(9,24,9)
ToolboxBox.BorderSizePixel = 0
ToolboxBox.ClearTextOnFocus = false
ToolboxBox.PlaceholderText = "Asset ID / URL..."
ToolboxBox.Text = ""
ToolboxBox.TextColor3 = Color3.fromRGB(240,240,240)
ToolboxBox.PlaceholderColor3 = Color3.fromRGB(36,120,36)
ToolboxBox.Font = Enum.Font.Gotham
ToolboxBox.TextSize = 9
Instance.new("UICorner", ToolboxBox).CornerRadius = UDim.new(0, 7)

local ToolboxInsert = Instance.new("TextButton", Right)
ToolboxInsert.Size = UDim2.new(1, -20, 0, 38)
ToolboxInsert.Position = UDim2.new(0, 10, 0, 132)
ToolboxInsert.BackgroundColor3 = Color3.fromRGB(30,110,30)
ToolboxInsert.BorderSizePixel = 0
ToolboxInsert.Text = "IMPORT SEKARANG"
ToolboxInsert.TextColor3 = Color3.new(1,1,1)
ToolboxInsert.Font = Enum.Font.GothamBold
ToolboxInsert.TextSize = 9
Instance.new("UICorner", ToolboxInsert).CornerRadius = UDim.new(0, 7)

local FilePathBox = Instance.new("TextBox", Right)
FilePathBox.Size = UDim2.new(1, -20, 0, 34)
FilePathBox.Position = UDim2.new(0, 10, 0, 176)
FilePathBox.BackgroundColor3 = Color3.fromRGB(9,24,9)
FilePathBox.BorderSizePixel = 0
FilePathBox.ClearTextOnFocus = false
FilePathBox.PlaceholderText = "Path RBXM / RBXMX..."
FilePathBox.Text = ""
FilePathBox.TextColor3 = Color3.fromRGB(240,240,240)
FilePathBox.PlaceholderColor3 = Color3.fromRGB(36,120,36)
FilePathBox.Font = Enum.Font.Gotham
FilePathBox.TextSize = 8
Instance.new("UICorner", FilePathBox).CornerRadius = UDim.new(0, 7)

local FileLoadBtn = Instance.new("TextButton", Right)
FileLoadBtn.Size = UDim2.new(1, -20, 0, 32)
FileLoadBtn.Position = UDim2.new(0, 10, 0, 216)
FileLoadBtn.BackgroundColor3 = Color3.fromRGB(16,48,16)
FileLoadBtn.BorderSizePixel = 0
FileLoadBtn.Text = "LOAD RBXM / RBXMX"
FileLoadBtn.TextColor3 = Color3.fromRGB(235,235,235)
FileLoadBtn.Font = Enum.Font.GothamBold
FileLoadBtn.TextSize = 8
Instance.new("UICorner", FileLoadBtn).CornerRadius = UDim.new(0, 7)

local Divider = Instance.new("TextLabel", Right)
Divider.Size = UDim2.new(1, -20, 0, 20)
Divider.Position = UDim2.new(0, 10, 0, 256)
Divider.BackgroundTransparency = 1
Divider.Text = "────────  atau  ────────"
Divider.TextColor3 = Color3.fromRGB(24,72,24)
Divider.Font = Enum.Font.Gotham
Divider.TextSize = 7

local Drop = Instance.new("TextLabel", Right)
Drop.Size = UDim2.new(1, -20, 0, 95)
Drop.Position = UDim2.new(0, 10, 0, 282)
Drop.BackgroundColor3 = Color3.fromRGB(10,30,10)
Drop.Text = "📁\nDrag & Drop File\nRBXM / RBXMX di sini"
Drop.TextColor3 = Color3.fromRGB(220,220,220)
Drop.Font = Enum.Font.GothamBold
Drop.TextSize = 9
Drop.TextWrapped = true
Instance.new("UICorner", Drop).CornerRadius = UDim.new(0, 8)
local DropStroke = Instance.new("UIStroke", Drop)
DropStroke.Color = Color3.fromRGB(22,68,22)
DropStroke.Thickness = 1

local Format = Instance.new("TextLabel", Right)
Format.Size = UDim2.new(1, -20, 0, 100)
Format.Position = UDim2.new(0, 10, 0, 388)
Format.BackgroundColor3 = Color3.fromRGB(10,30,10)
Format.Text = "FORMAT DIDUKUNG\n\n✓ RBXM\n✓ RBXMX (PAID)\n✓ Model .rbxl\n✓ Audio .mp3 / .ogg"
Format.TextColor3 = Color3.fromRGB(165,165,165)
Format.Font = Enum.Font.Gotham
Format.TextSize = 8
Format.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Format).CornerRadius = UDim.new(0, 8)

-- PAGE WIRING
-- Forward declarations so navigation can safely reference objects/functions
-- that are constructed a few lines later.
local PagePanel
local ScanBtn
local showDashboardPanel, showSettingsPanel, showCreditsPanel
local function showPage(page)
    ActivePage = page
    local indexMap = {DASHBOARD=1, TOOLBOX=2, RBXM=3, RBXMX=4, SETTINGS=5, CREDITS=6}
    setSideActive(indexMap[page] or 2)

    -- Default: toolbox/search visible.
    Content.Visible = true
    Right.Visible = (page == "TOOLBOX" or page == "DASHBOARD" or page == "RBXM" or page == "RBXMX")
    if PagePanel then
        PagePanel.Visible = (page == "DASHBOARD" or page == "SETTINGS" or page == "CREDITS")
    end
    if ScanBtn then
        ScanBtn.Visible = (page == "RBXM" or page == "RBXMX")
    end

    if page == "TOOLBOX" then
        TitleText.Text = "TOOLBOX"
        Subtitle.Text = "Cari & import asset dari Roblox Creator Store"
        SearchRow.Visible = true; TypeTabs.Visible = true; SearchHead.Visible = true; SearchScroll.Visible = true
        Right.Visible = true
        if PagePanel then PagePanel.Visible = false end
    elseif page == "DASHBOARD" then
        TitleText.Text = "DASHBOARD"
        Subtitle.Text = "Pusat kontrol NANG RBXM — semua menu punya fungsi sendiri"
        SearchRow.Visible = false; TypeTabs.Visible = false; SearchHead.Visible = false; SearchScroll.Visible = false
        Right.Visible = false
        if PagePanel then showDashboardPanel() end

    elseif page == "RBXM" or page == "RBXMX" then
        TitleText.Text = page
        Subtitle.Text = "FULL ACCESS • Scan file dan tekan INSERT pada file yang ditemukan"
        SearchRow.Visible = false; TypeTabs.Visible = false; SearchHead.Visible = true; SearchScroll.Visible = true
        SearchHead.Text = "  FILE IMPORT  •  " .. page
        Right.Visible = true
        if page == "RBXMX" then
            Format.Text = "FORMAT DIDUKUNG\n\n✓ RBXMX\n✓ RBXM\n\nTekan SCAN FILES untuk menampilkan file."
        else
            Format.Text = "FORMAT DIDUKUNG\n\n✓ RBXM\n✓ RBXMX\n\nTekan SCAN FILES untuk menampilkan file."
        end

    elseif page == "SETTINGS" then
        TitleText.Text = "SETTINGS"
        Subtitle.Text = "Pengaturan yang benar-benar mengubah perilaku UI"
        SearchRow.Visible = false; TypeTabs.Visible = false; SearchHead.Visible = false; SearchScroll.Visible = false
        Right.Visible = false
        if PagePanel then showSettingsPanel() end
    elseif page == "CREDITS" then
        TitleText.Text = "CREDITS"
        Subtitle.Text = "Informasi fitur NANG RBXM"
        SearchRow.Visible = false; TypeTabs.Visible = false; SearchHead.Visible = false; SearchScroll.Visible = false
        Right.Visible = false
        if PagePanel then showCreditsPanel() end
    end
end

for i, btn in ipairs(sideButtons) do
    btn.MouseButton1Click:Connect(function()
        local pages = {"DASHBOARD","TOOLBOX","RBXM","RBXMX","SETTINGS","CREDITS"}
        showPage(pages[i])
    end)
end

-- Legacy scan button retained but moved into sidebar/import behavior
ScanBtn = Instance.new("TextButton", Sidebar)
ScanBtn.Size = UDim2.new(1, -20, 0, 30)
ScanBtn.Position = UDim2.new(0, 10, 1, -128)
ScanBtn.BackgroundColor3 = Color3.fromRGB(10,28,10)
ScanBtn.Text = "↻  SCAN FILES"
ScanBtn.TextColor3 = Color3.fromRGB(210,210,210)
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.TextSize = 8
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)
local ScanClick = ScanBtn
local ScanIcon = Instance.new("ImageLabel", ScanBtn)
ScanIcon.Visible = false
local ScanText = ScanBtn

-- Legacy Scroll kept for RBXM/RBXL scanner cards; hidden until scan.
Scroll = Instance.new("ScrollingFrame", UI)
Scroll.Visible = false
Scroll.Size = UDim2.new(0, 1, 0, 1)
Scroll.Position = UDim2.new(0,0,0,0)
Scroll.BackgroundTransparency = 1
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local LegacyLayout = Instance.new("UIListLayout", Scroll)
LegacyLayout.Padding = UDim.new(0,5)
EmptyFrame = Instance.new("Frame", Scroll)
EmptyFrame.Size = UDim2.new(1,0,0,1)
EmptyFrame.BackgroundTransparency = 1
local EmptyLabel = Instance.new("TextLabel", EmptyFrame)
EmptyLabel.Size = UDim2.new(1,0,1,0)
EmptyLabel.BackgroundTransparency = 1
EmptyLabel.Text = ""

local StatsBar = Instance.new("Frame", Main)
StatsBar.Size = UDim2.new(1, -390, 0, 22)
StatsBar.Position = UDim2.new(0, 190, 1, -28)
StatsBar.BackgroundColor3 = Color3.fromRGB(22,22,22)
StatsBar.BorderSizePixel = 0
Instance.new("UICorner", StatsBar).CornerRadius = UDim.new(0, 6)
local StatsText = Instance.new("TextLabel", StatsBar)
StatsText.Size = UDim2.new(1,-12,1,0)
StatsText.Position = UDim2.new(0,6,0,0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "Status: Ready  |  Files: 0"
StatsText.TextColor3 = Color3.fromRGB(140,140,140)
StatsText.Font = Enum.Font.Gotham
StatsText.TextSize = 8
StatsText.TextXAlignment = Enum.TextXAlignment.Left

-- NOTIFICATION SYSTEM WITH VECTOR BELL ICON
notify = function(title, msg, color)
    color = color or Color3.fromRGB(95,215,95)
    local notif = Instance.new("Frame", UI)
    notif.Size = UDim2.new(0, 220, 0, 42)
    notif.Position = UDim2.new(1, -230, 1, -55)
    notif.BackgroundColor3 = Color3.fromRGB(18,18,18)
    notif.BorderSizePixel = 0
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 6)

    local notifStroke = Instance.new("UIStroke", notif)
    notifStroke.Thickness = 1
    notifStroke.Color = color

    local icon = Instance.new("ImageLabel", notif)
    icon.Size = UDim2.new(0, 14, 0, 14)
    icon.Position = UDim2.new(0, 8, 0, 6)
    icon.BackgroundTransparency = 1
    icon.Image = ICONS.BELL
    icon.ImageColor3 = color

    local t = Instance.new("TextLabel", notif)
    t.Size = UDim2.new(1, -28, 0, 14); t.Position = UDim2.new(0, 26, 0, 4)
    t.BackgroundTransparency = 1; t.Text = title
    t.TextColor3 = Color3.fromRGB(239,239,239); t.Font = Enum.Font.GothamBold
    t.TextSize = 10; t.TextXAlignment = Enum.TextXAlignment.Left

    local d = Instance.new("TextLabel", notif)
    d.Size = UDim2.new(1, -12, 0, 16); d.Position = UDim2.new(0, 8, 0, 18)
    d.BackgroundTransparency = 1; d.Text = msg
    d.TextColor3 = Color3.fromRGB(90,180,90); d.Font = Enum.Font.Gotham
    d.TextSize = 8; d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextWrapped = true

    task.spawn(function()
        task.wait(2.5)
        for i = 1, 12 do
            notif.BackgroundTransparency = i / 12
            icon.ImageTransparency = i / 12
            t.TextTransparency = i / 12
            d.TextTransparency = i / 12
            task.wait(0.02)
        end
        notif:Destroy()
    end)
end

-- ======================================================================
-- REAL PAGE PANELS
-- Sidebar menus are functional: each page gets its own controls.
-- ======================================================================
PagePanel = Instance.new("Frame", Content)
PagePanel.Name = "PagePanel"
PagePanel.Size = UDim2.new(1, 0, 1, 0)
PagePanel.Position = UDim2.new(0, 0, 0, 0)
PagePanel.BackgroundTransparency = 1
PagePanel.Visible = false
PagePanel.ZIndex = 20

local pageViews = {}
local function clearPageView()
    for _, child in ipairs(PagePanel:GetChildren()) do
        child:Destroy()
    end
end
local function panelLabel(text, pos, size, fontSize, color)
    local l = Instance.new("TextLabel", PagePanel)
    l.BackgroundTransparency = 1
    l.Position = pos
    l.Size = size
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(230,230,230)
    l.Font = Enum.Font.Gotham
    l.TextSize = fontSize or 10
    l.TextWrapped = true
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Top
    return l
end
local function panelButton(text, pos, size, callback, accent)
    local b = Instance.new("TextButton", PagePanel)
    b.Position = pos; b.Size = size
    b.BackgroundColor3 = accent or Color3.fromRGB(40,160,40)
    b.BorderSizePixel = 0; b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold; b.TextSize = 9
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(callback)
    return b
end
local function panelBox(placeholder, pos, size)
    local b = Instance.new("TextBox", PagePanel)
    b.Position = pos; b.Size = size
    b.BackgroundColor3 = Color3.fromRGB(8,22,8)
    b.BorderSizePixel = 0; b.ClearTextOnFocus = false
    b.PlaceholderText = placeholder; b.Text = ""
    b.TextColor3 = Color3.fromRGB(240,240,240)
    b.PlaceholderColor3 = Color3.fromRGB(110,110,110)
    b.Font = Enum.Font.Code; b.TextSize = 9
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextYAlignment = Enum.TextYAlignment.Top
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

showDashboardPanel = function()
    clearPageView(); PagePanel.Visible = true
    panelLabel("NANG RBXM CONTROL CENTER", UDim2.new(0,10,0,10), UDim2.new(1,-20,0,30), 18, Color3.fromRGB(40,160,40))
    panelLabel("Pilih menu di kiri. Sekarang setiap menu membuka fungsi yang berbeda, bukan halaman kosong.", UDim2.new(0,10,0,46), UDim2.new(1,-20,0,36), 9, Color3.fromRGB(145,145,145))
    local cards = {
        {"TOOLBOX", "Search Creator Store + INSERT", "TOOLBOX"},

        {"RBXM • FULL", "Scan dan INSERT RBXM", "RBXM"},
        {"RBXMX • FULL", "Scan dan INSERT RBXMX", "RBXMX"},

        {"SETTINGS", "UI behavior", "SETTINGS"},
    }
    for i, c in ipairs(cards) do
        local col = (i-1)%2; local row = math.floor((i-1)/2)
        local x = col*245; local y = 92 + row*82
        local f = Instance.new("Frame", PagePanel)
        f.Position = UDim2.new(0,x,0,y); f.Size = UDim2.new(0,230,0,70)
        f.BackgroundColor3 = Color3.fromRGB(8,20,8); f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
        panelLabel(c[1], UDim2.new(0,x+12,0,y+10), UDim2.new(0,210,0,20), 11, Color3.fromRGB(118,118,118))
        panelLabel(c[2], UDim2.new(0,x+12,0,y+32), UDim2.new(0,150,0,26), 8, Color3.fromRGB(150,150,150))
        panelButton("OPEN", UDim2.new(0,x+172,0,y+20), UDim2.new(0,48,0,28), function() showPage(c[3]) end, Color3.fromRGB(12,36,12))
    end
end

showSettingsPanel = function()
    clearPageView(); PagePanel.Visible = true
    panelLabel("SETTINGS", UDim2.new(0,10,0,10), UDim2.new(1,-20,0,28), 18, Color3.fromRGB(40,160,40))
    panelLabel("Pengaturan di bawah ini langsung mengubah UI.", UDim2.new(0,10,0,42), UDim2.new(1,-20,0,24), 9, Color3.fromRGB(145,145,145))
    local posLabel = panelLabel("Window position: current", UDim2.new(0,10,0,90), UDim2.new(0,260,0,30), 10, Color3.fromRGB(220,220,220))
    panelButton("RESET POSITION", UDim2.new(0,290,0,84), UDim2.new(0,145,0,38), function()
        Main.Position = UDim2.new(0.5,-460,0.5,-290)
        posLabel.Text = "Window position: reset"
    end, Color3.fromRGB(20,58,20))
    panelButton("TOOLBOX", UDim2.new(0,10,0,145), UDim2.new(0,130,0,38), function() showPage("TOOLBOX") end)
    panelButton("DASHBOARD", UDim2.new(0,150,0,145), UDim2.new(0,130,0,38), function() showPage("DASHBOARD") end)
    panelLabel("UI Scale", UDim2.new(0,10,0,205), UDim2.new(0,100,0,24), 10, Color3.fromRGB(220,220,220))
    panelButton("FIT SCREEN", UDim2.new(0,120,0,198), UDim2.new(0,130,0,38), function()
        fitUI(); notify("Settings", "UI scale disesuaikan dengan layar.", Color3.fromRGB(80,200,80))
    end, Color3.fromRGB(20,58,20))
end

showCreditsPanel = function()
    clearPageView(); PagePanel.Visible = true
    panelLabel("NANG RBXM", UDim2.new(0,10,0,12), UDim2.new(1,-20,0,32), 22, Color3.fromRGB(40,160,40))
    panelLabel("RBXM / RBXMX Importer\nCreator Store Search\nToolbox Asset Insert\nStudio Lite integration\n\nMenu sidebar dibuat sebagai halaman fungsional, bukan tombol pajangan.", UDim2.new(0,10,0,58), UDim2.new(1,-20,0,150), 10, Color3.fromRGB(85,205,85))
    panelButton("BACK TO DASHBOARD", UDim2.new(0,10,0,220), UDim2.new(0,170,0,40), function() showPage("DASHBOARD") end, Color3.fromRGB(12,36,12))
end

-- CARD BUILDER WITH VECTOR BADGES & DOWNLOAD ICON
local totalLoaded = 0

local function buildFileCard(fileInfo)
    EmptyFrame.Visible = false

    local card = Instance.new("Frame", Scroll)
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Color3.fromRGB(8,22,8)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Thickness = 1
    cardStroke.Color = Color3.fromRGB(22,68,22)

    local isRbxl = fileInfo.ftype == "RBXL"

    local typeBadge = Instance.new("Frame", card)
    typeBadge.Size = UDim2.new(0, 48, 0, 16); typeBadge.Position = UDim2.new(0, 6, 0, 6)
    typeBadge.BackgroundColor3 = isRbxl and Color3.fromRGB(85,205,85) or Color3.fromRGB(30,115,30)
    typeBadge.BorderSizePixel = 0
    Instance.new("UICorner", typeBadge).CornerRadius = UDim.new(0, 4)

    local badgeIcon = Instance.new("ImageLabel", typeBadge)
    badgeIcon.Size = UDim2.new(0, 10, 0, 10)
    badgeIcon.Position = UDim2.new(0, 4, 0.5, -5)
    badgeIcon.BackgroundTransparency = 1
    badgeIcon.Image = isRbxl and ICONS.GAMEPAD or ICONS.FILE
    badgeIcon.ImageColor3 = Color3.fromRGB(8,20,8)

    local typeText = Instance.new("TextLabel", typeBadge)
    typeText.Size = UDim2.new(1, -16, 1, 0); typeText.Position = UDim2.new(0, 16, 0, 0)
    typeText.BackgroundTransparency = 1
    typeText.Text = fileInfo.ftype
    typeText.TextColor3 = Color3.fromRGB(8,20,8)
    typeText.Font = Enum.Font.GothamBold; typeText.TextSize = 8

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1, -135, 0, 16); nameLbl.Position = UDim2.new(0, 60, 0, 6)
    nameLbl.BackgroundTransparency = 1; nameLbl.Text = fileInfo.name
    nameLbl.TextColor3 = Color3.fromRGB(234,234,234); nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 10; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local pathLbl = Instance.new("TextLabel", card)
    pathLbl.Size = UDim2.new(1, -135, 0, 12); pathLbl.Position = UDim2.new(0, 60, 0, 22)
    pathLbl.BackgroundTransparency = 1; pathLbl.Text = fileInfo.path
    pathLbl.TextColor3 = Color3.fromRGB(152,152,152); pathLbl.Font = Enum.Font.Gotham
    pathLbl.TextSize = 8; pathLbl.TextXAlignment = Enum.TextXAlignment.Left
    pathLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local insertFrame = Instance.new("Frame", card)
    insertFrame.Size = UDim2.new(0, 66, 0, 24); insertFrame.Position = UDim2.new(1, -72, 0.5, -12)
    insertFrame.BackgroundColor3 = Color3.fromRGB(18,52,18)
    Instance.new("UICorner", insertFrame).CornerRadius = UDim.new(0, 4)

    local btnStroke = Instance.new("UIStroke", insertFrame)
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(70,190,70)

    local insertIcon = Instance.new("ImageLabel", insertFrame)
    insertIcon.Size = UDim2.new(0, 10, 0, 10)
    insertIcon.Position = UDim2.new(0, 6, 0.5, -5)
    insertIcon.BackgroundTransparency = 1
    insertIcon.Image = ICONS.DOWNLOAD
    insertIcon.ImageColor3 = Color3.fromRGB(236,236,236)

    local insertText = Instance.new("TextLabel", insertFrame)
    insertText.Size = UDim2.new(1, -18, 1, 0); insertText.Position = UDim2.new(0, 18, 0, 0)
    insertText.BackgroundTransparency = 1; insertText.Text = "INSERT"
    insertText.TextColor3 = Color3.fromRGB(236,236,236)
    insertText.Font = Enum.Font.GothamBold; insertText.TextSize = 8

    local insertBtn = Instance.new("TextButton", insertFrame)
    insertBtn.Size = UDim2.new(1, 0, 1, 0)
    insertBtn.BackgroundTransparency = 1
    insertBtn.Text = ""

    insertBtn.MouseEnter:Connect(function() TweenService:Create(insertFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(26,90,26)}):Play() end)
    insertBtn.MouseLeave:Connect(function() TweenService:Create(insertFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18,52,18)}):Play() end)

    insertBtn.MouseButton1Click:Connect(function()
        if insertText.Text == "LOADING" then return end
        insertText.Text = "LOADING"; insertIcon.Image = ICONS.REFRESH
        insertFrame.BackgroundColor3 = Color3.fromRGB(20,62,20)

        task.spawn(function()
            local ok, msg = loadFile(fileInfo)
            if ok then
                insertText.Text = "DONE"; insertIcon.Image = ICONS.CHECK
                insertFrame.BackgroundColor3 = Color3.fromRGB(80,200,80)
                totalLoaded = totalLoaded + 1
                StatsText.Text = string.format("Status: Ready  |  Files: %d  |  Loaded: %d", #Scroll:GetChildren() - 1, totalLoaded)
                notify("Success", fileInfo.name .. " dimuat!", Color3.fromRGB(95,215,95))
            else
                insertText.Text = "FAIL"; insertIcon.Image = ICONS.ALERT
                insertFrame.BackgroundColor3 = Color3.fromRGB(22,67,22)
                notify("Gagal", msg, Color3.fromRGB(110,110,110))
            end
            task.wait(2)
            insertText.Text = "INSERT"; insertIcon.Image = ICONS.DOWNLOAD
            insertFrame.BackgroundColor3 = Color3.fromRGB(18,52,18)
        end)
    end)
end


local function buildModernFileCard(fileInfo)
    if not SearchScroll then return end
    SearchEmptyFrame.Visible = false
    local card = Instance.new("Frame", SearchScroll)
    card.Size = UDim2.new(0, 150, 0, 178)
    card.BackgroundColor3 = Color3.fromRGB(8,22,8)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = Color3.fromRGB(58,58,58)
    stroke.Thickness = 1

    local badge = Instance.new("TextLabel", card)
    badge.Size = UDim2.new(1,-12,0,28)
    badge.Position = UDim2.new(0,6,0,8)
    badge.BackgroundColor3 = fileInfo.ftype == "RBXM" and Color3.fromRGB(40,160,40) or Color3.fromRGB(42,148,42)
    badge.Text = fileInfo.ftype
    badge.TextColor3 = Color3.new(1,1,1)
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 12
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0,7)

    local name = Instance.new("TextLabel", card)
    name.Size = UDim2.new(1,-12,0,38)
    name.Position = UDim2.new(0,6,0,46)
    name.BackgroundTransparency = 1
    name.Text = tostring(fileInfo.name)
    name.TextColor3 = Color3.fromRGB(240,240,240)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 9
    name.TextWrapped = true
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextYAlignment = Enum.TextYAlignment.Top

    local path = Instance.new("TextLabel", card)
    path.Size = UDim2.new(1,-12,0,30)
    path.Position = UDim2.new(0,6,0,86)
    path.BackgroundTransparency = 1
    path.Text = tostring(fileInfo.path)
    path.TextColor3 = Color3.fromRGB(115,115,115)
    path.Font = Enum.Font.Gotham
    path.TextSize = 6
    path.TextWrapped = true
    path.TextXAlignment = Enum.TextXAlignment.Left
    path.TextYAlignment = Enum.TextYAlignment.Top

    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(1,-12,0,30)
    btn.Position = UDim2.new(0,6,1,-36)
    btn.BackgroundColor3 = Color3.fromRGB(40,160,40)
    btn.Text = "INSERT"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function()
        if btn.Text == "LOADING..." then return end
        btn.Text = "LOADING..."
        task.spawn(function()
            local ok, msg = loadFile(fileInfo)
            if ok then
                btn.Text = "DONE"
                btn.BackgroundColor3 = Color3.fromRGB(52,162,52)
                notify("RBXM Import", tostring(fileInfo.name) .. " berhasil dimasukkan.", Color3.fromRGB(80,200,80))
            else
                btn.Text = "FAIL"
                btn.BackgroundColor3 = Color3.fromRGB(24,78,24)
                notify("RBXM Gagal", tostring(msg), Color3.fromRGB(122,122,122))
            end
            task.wait(1.3)
            btn.Text = "INSERT"
            btn.BackgroundColor3 = Color3.fromRGB(40,160,40)
        end)
    end)
end

local creatorPage = 0
local creatorSearching = false
local creatorNextCursor = nil
local creatorTotalFound = 0
local creatorKeyword = ""
local creatorType = "MODEL"

-- Load More button
local LoadMoreBtn = Instance.new("TextButton", SearchScroll)
LoadMoreBtn.Size = UDim2.new(1, -20, 0, 36)
LoadMoreBtn.BackgroundColor3 = Color3.fromRGB(10,30,10)
LoadMoreBtn.BorderSizePixel = 0
LoadMoreBtn.Text = "LOAD MORE"
LoadMoreBtn.TextColor3 = Color3.fromRGB(200,200,200)
LoadMoreBtn.Font = Enum.Font.GothamBold
LoadMoreBtn.TextSize = 10
LoadMoreBtn.LayoutOrder = 99999
LoadMoreBtn.Visible = false
Instance.new("UICorner", LoadMoreBtn).CornerRadius = UDim.new(0, 8)
local LoadMoreStroke = Instance.new("UIStroke", LoadMoreBtn)
LoadMoreStroke.Color = Color3.fromRGB(22,68,22)
LoadMoreStroke.Thickness = 1

local function appendSearchResults(results, nextCursor)
    for _, info in ipairs(results) do buildModelResultCard(info) end
    creatorTotalFound = creatorTotalFound + #results
    creatorNextCursor = nextCursor
    StatsText.Text = string.format("Status: Creator Store  |  %d %s ditemukan", creatorTotalFound, creatorType)
    LoadMoreBtn.Visible = (nextCursor ~= nil and nextCursor ~= "")
    LoadMoreBtn.Text = "LOAD MORE (" .. tostring(creatorTotalFound) .. " loaded)"
end

local function runCreatorSearch()
    if creatorSearching then return end
    local keyword = SearchModelBox.Text
    if tostring(keyword):gsub("%s+", "") == "" then
        notify("Creator Store", "Ketik nama asset terlebih dahulu.", Color3.fromRGB(189,189,189))
        return
    end

    creatorSearching = true
    creatorPage = 0
    creatorNextCursor = nil
    creatorTotalFound = 0
    creatorKeyword = keyword
    creatorType = SearchType
    SearchModelBtn.Text = "SEARCH..."
    clearScrollCards()
    LoadMoreBtn.Visible = false
    SearchEmptyFrame.Visible = true
    SearchEmptyFrame:FindFirstChildOfClass("TextLabel").Text = "Mencari " .. SearchType .. " di Creator Store..."

    task.spawn(function()
        local ok, results, cursor = searchCreatorModels(keyword, creatorPage, SearchType)
        if ok then
            SearchEmptyFrame.Visible = (#results == 0)
            if #results == 0 then
                SearchEmptyFrame:FindFirstChildOfClass("TextLabel").Text = SearchType .. " tidak ditemukan.\nCoba kata kunci lain."
            else
                appendSearchResults(results, cursor)
                notify("Creator Store", #results .. " " .. SearchType .. " ditemukan.", Color3.fromRGB(90,180,90))
            end
        else
            SearchEmptyFrame.Visible = true
            SearchEmptyFrame:FindFirstChildOfClass("TextLabel").Text = "Pencarian gagal.\n" .. tostring(results)
            notify("Creator Store Gagal", tostring(results), Color3.fromRGB(122,122,122))
        end
        SearchModelBtn.Text = "SEARCH"
        creatorSearching = false
    end)
end

LoadMoreBtn.MouseButton1Click:Connect(function()
    if creatorSearching then return end
    if not creatorNextCursor or creatorNextCursor == "" then return end
    creatorSearching = true
    creatorPage = creatorPage + 1
    LoadMoreBtn.Text = "MEMUAT..."
    task.spawn(function()
        local ok, results, cursor = searchCreatorModels(creatorKeyword, creatorPage, creatorType)
        if ok and #results > 0 then
            appendSearchResults(results, cursor)
            notify("Creator Store", #results .. " " .. creatorType .. " lagi dimuat.", Color3.fromRGB(90,180,90))
        elseif ok then
            LoadMoreBtn.Visible = false
            notify("Creator Store", "Tidak ada hasil lagi.", Color3.fromRGB(90,180,90))
        else
            notify("Load More Gagal", tostring(results), Color3.fromRGB(122,122,122))
            LoadMoreBtn.Text = "LOAD MORE (" .. tostring(creatorTotalFound) .. " loaded)"
        end
        creatorSearching = false
    end)
end)

SearchModelBtn.MouseButton1Click:Connect(runCreatorSearch)
SearchModelBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then runCreatorSearch() end
end)

ToolboxInsert.MouseButton1Click:Connect(function()
    local value = tostring(ToolboxBox.Text or ""):gsub("%s+", "")
    if value == "" then
        notify("Quick Import", "Masukkan Asset ID atau URL.", Color3.fromRGB(189,189,189))
        return
    end
    if ToolboxInsert.Text == "LOADING..." then return end
    ToolboxInsert.Text = "LOADING..."
    task.spawn(function()
        local quickId = tostring(value):match("(%d+)") or "Asset"
        local ok, msg = insertToolboxAsset(value, SearchType, "Music_" .. quickId)
        if ok then
            ToolboxInsert.Text = "DONE"
            if tostring(SearchType):upper() == "AUDIO" then
                notify("Music", "Audio berhasil ditambahkan ke SoundService: " .. tostring(msg), Color3.fromRGB(80,200,80))
            else
                notify("Toolbox", "Asset berhasil diinsert: " .. tostring(msg), Color3.fromRGB(80,200,80))
            end
        else
            ToolboxInsert.Text = "FAIL"
            notify("Toolbox Gagal", tostring(msg), Color3.fromRGB(122,122,122))
        end
        task.wait(1.3)
        ToolboxInsert.Text = "IMPORT SEKARANG"
    end)
end)

-- SCAN LOGIC
ScanClick.MouseButton1Click:Connect(function()
    ScanText.Text = "⟳  SCANNING..."
    clearScrollCards()
    SearchEmptyFrame.Visible = true
    SearchEmptyFrame:FindFirstChildOfClass("TextLabel").Text = "Mencari file RBXM / RBXMX / RBXL..."
    task.spawn(function()
        local scanned = scanAll()
        local foundFiles = {}
        for _, f in ipairs(scanned) do
            if ActivePage == "RBXMX" then
                if f.path:lower():match("%.rbxmx$") then table.insert(foundFiles, f) end
            elseif ActivePage == "RBXM" then
                if f.path:lower():match("%.rbxm$") then table.insert(foundFiles, f) end
            else
                table.insert(foundFiles, f)
            end
        end
        for _, f in ipairs(foundFiles) do buildModernFileCard(f) end
        SearchEmptyFrame.Visible = (#foundFiles == 0)
        StatsText.Text = string.format("Status: Ready  |  %d %s file(s)", #foundFiles, ActivePage)
        ScanText.Text = "↻  SCAN FILES"
        if #foundFiles == 0 then
            notify("Scan", "Tidak ada file RBXM/RBXMX/RBXL yang ditemukan.", Color3.fromRGB(189,189,189))
        else
            notify("Scan Selesai", #foundFiles .. " file terdeteksi.", Color3.fromRGB(80,200,80))
        end
    end)
end)

FileLoadBtn.MouseButton1Click:Connect(function()
    local path = tostring(FilePathBox.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if path == "" then
        notify("RBXM", "Masukkan path file RBXM/RBXMX.", Color3.fromRGB(189,189,189))
        return
    end
    local lower = path:lower()
    local ftype = (lower:match("%.rbxmx$") or lower:match("%.rbxm$")) and "RBXM" or nil
    if not ftype then
        notify("RBXM", "File harus berformat .rbxm atau .rbxmx.", Color3.fromRGB(122,122,122))
        return
    end
    FileLoadBtn.Text = "LOADING..."
    task.spawn(function()
        local ok, msg = loadFile({name = path:match("([^/]+)$") or path, path = path, ftype = ftype})
        if ok then
            FileLoadBtn.Text = "DONE"
            notify("RBXM Import", tostring(msg), Color3.fromRGB(80,200,80))
        else
            FileLoadBtn.Text = "FAIL"
            notify("RBXM Gagal", tostring(msg), Color3.fromRGB(122,122,122))
        end
        task.wait(1.3)
        FileLoadBtn.Text = "LOAD RBXM / RBXMX"
    end)
end)

-- MINIMIZE / CLOSE
-- Close only hides the panel; the toggle below the Roblox menu stays available.
CloseClick.MouseButton1Click:Connect(function()
    if Main.Visible then
        toggleMain()
    end
end)

local minimized = false
MinClick.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        StatsBar.Visible = false
        Main.Size = UDim2.new(0, 920, 0, 70)
    else
        Content.Visible = true
        StatsBar.Visible = true
        Main.Size = UDim2.new(0, 780, 0, 500)
    end
end)


-- Initial visible page: Toolbox, so every important feature is immediately visible.
showPage("TOOLBOX")

-- FLY REMOVED: this build is intentionally focused on asset tools.


end

local __NANG_OK, __NANG_ERR = xpcall(__NANG_RUN_MAIN, function(err)
    return debug and debug.traceback and debug.traceback(tostring(err), 2) or tostring(err)
end)
__NANG_MAIN_OK = __NANG_OK
__NANG_MAIN_ERR = __NANG_ERR

if not __NANG_OK then
    warn("[NANG RBXM] Safe Execute caught an error:\n" .. tostring(__NANG_ERR))

    -- Emergency UI: memastikan Execute tetap memberi feedback meski fitur
    -- optional/environment-specific gagal diinisialisasi.
    pcall(function()
        local Players = game:GetService("Players")
        local CoreGui = game:GetService("CoreGui")
        local player = Players.LocalPlayer
        local parent = CoreGui
        pcall(function()
            if not parent then parent = player:WaitForChild("PlayerGui") end
        end)
        if not parent then parent = player:WaitForChild("PlayerGui") end

        local old = parent:FindFirstChild("NANG_SAFE_EXECUTE_STATUS")
        if old then old:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name = "NANG_SAFE_EXECUTE_STATUS"
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 999999
        gui.Parent = parent

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 360, 0, 150)
        frame.Position = UDim2.new(0.5, -180, 0.08, 0)
        frame.BackgroundColor3 = Color3.fromRGB(8,22,8)
        frame.BorderSizePixel = 0
        frame.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -30, 0, 32)
        title.Position = UDim2.new(0, 15, 0, 12)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 17
        title.TextColor3 = Color3.fromRGB(235,235,235)
        title.Text = "NANG RBXM • SAFE EXECUTE"
        title.Parent = frame

        local status = Instance.new("TextLabel")
        status.BackgroundTransparency = 1
        status.Size = UDim2.new(1, -30, 0, 55)
        status.Position = UDim2.new(0, 15, 0, 48)
        status.Font = Enum.Font.Gotham
        status.TextSize = 12
        status.TextWrapped = true
        status.TextXAlignment = Enum.TextXAlignment.Left
        status.TextYAlignment = Enum.TextYAlignment.Top
        status.TextColor3 = Color3.fromRGB(206,206,206)
        status.Text = "Script berhasil Execute, tetapi ada fitur yang gagal dimuat.\nFREE tetap dapat dijalankan setelah error diperbaiki."
        status.Parent = frame

        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 90, 0, 28)
        close.Position = UDim2.new(1, -105, 1, -38)
        close.BackgroundColor3 = Color3.fromRGB(22,66,22)
        close.BorderSizePixel = 0
        close.Font = Enum.Font.GothamBold
        close.TextSize = 11
        close.TextColor3 = Color3.fromRGB(240,240,240)
        close.Text = "CLOSE"
        close.Parent = frame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 7)
        c.Parent = close
        close.MouseButton1Click:Connect(function() gui:Destroy() end)
    end)
end
