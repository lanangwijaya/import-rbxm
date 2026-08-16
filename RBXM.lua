--[[
    ╔══════════════════════════════════════════════════════════════════════╗
    ║  NANG RBXM v63.0 - Modern UI Edition    ║
    ║  Features: Modern UI, Smooth Animations, Verified Asset Mapping           ║
    ║  Supports: RBXM, RBXL, RBXLX, RBXMX                                  ║
    ╚══════════════════════════════════════════════════════════════════════╝
]]

if not game:IsLoaded() then game.Loaded:Wait() end

-- ═══════════════════════════════════════════════════════════════════════
-- WHITELIST GATE — LANGZ PAID SCRIPT
-- ═══════════════════════════════════════════════════════════════════════
local _WHITELIST = {
    -- Masukkan UserId yang boleh akses di sini
    8236629801,
    10370966620
}

local _userId = game:GetService("Players").LocalPlayer.UserId
local _allowed = false
for _, id in ipairs(_WHITELIST) do
    if id == _userId then _allowed = true; break end
end

if not _allowed then
    warn("have you tried opening this script it's not easy my friend 😈😈😈😈")
    warn("KALO KALIAN MAU BELI IMPORT RBXM NYA LANGSUNG AJA HUBUNGI NANG DI NOMOR INI, 081252425581 NANG 👑")
    return
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

    local function buildSourceMap(node, path)
        local src = node.Properties["Source"] or node.Properties["ContentText"]
        if src and type(src) == "string" and #src > 0 then sources[path] = src end
        for _, child in ipairs(node.Children or {}) do buildSourceMap(child, path .. "." .. child.ClassName .. ":" .. (child.Properties["Name"] or "unnamed")) end
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
local function injectStudioLiteUI(scr, sourceMap)
    if not scr:IsA("LuaSourceContainer") then return end
    local path = scr.ClassName .. ":" .. scr.Name
    local realSource = sourceMap and sourceMap[path]
    if not realSource then pcall(function() realSource = scr.Source end) end
    if realSource and #realSource > 0 then realSource = (realSource:gsub(string.char(0).."*$", "")) else realSource = "-- [LANGZ] Source tidak ditemukan." end

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
        return
    end

    if not serverFuncs then return end
    local map = { Script = "InsertScriptScript", LocalScript = "InsertLocalScriptLocalScript", ModuleScript = "InsertModuleScriptModuleScript" }
    local assetName = map[scr.ClassName]
    if not assetName then return end

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
    if not SL_CACHE[assetName] then return end

    pcall(function()
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
end

local function injectAllScripts(root, sourceMap)
    if not root then return 0 end
    local list = {}
    if root:IsA("LuaSourceContainer") then table.insert(list, root) end
    for _, d in ipairs(root:GetDescendants()) do if d:IsA("LuaSourceContainer") then table.insert(list, d) end end
    local count = 0
    for _, s in ipairs(list) do pcall(injectStudioLiteUI, s, sourceMap); count = count + 1; task.wait(0.02) end
    return count
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

local function safeReadFile(p) if not readfile then return nil end; local ok, d = pcall(readfile, p); return ok and d or nil end

local function loadFile(fileInfo)
    local isRbxl = fileInfo.ftype == "RBXL"
    local data = safeReadFile(fileInfo.path)
    if not data or #data == 0 then return false, "readfile gagal" end

    local sourceMap = {}
    if not isRbxl then
        local ok, sources, err = pcall(parseRBXMForSources, data)
        if ok and sources then sourceMap = sources end
    end

    if getcustomasset then
        local ok1, aid = pcall(getcustomasset, fileInfo.path)
        if ok1 and aid then
            local ok2, objs = pcall(function() return game:GetObjects(aid) end)
            if ok2 and objs and #objs > 0 then return true, insertObjects(objs, isRbxl, sourceMap) .. " object(s) loaded" end
        end
    end

    local ok3, o3 = pcall(function() return game:GetObjects("rbxasset://" .. fileInfo.path) end)
    if ok3 and o3 and #o3 > 0 then return true, insertObjects(o3, isRbxl, sourceMap) .. " object(s) loaded" end

    return false, "Semua metode load gagal"
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

local SCAN_PATHS = { "workspace", "Delta/workspace", "delta/workspace", "Android/Delta/workspace", "/sdcard/Delta/workspace", "/sdcard/Android/Delta/workspace", "../workspace", ".", "" }

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
    pcall(function() injectAllScripts(inserted,{}); ApplyStudioLiteProperties(inserted); LoadAssetsToSLServer(inserted) end)
    return true,inserted.Name
end


-- ═══════════════════════════════════════════════════════════════════════
-- CREATOR STORE MODEL SEARCH
-- ═══════════════════════════════════════════════════════════════════════
local Scroll, EmptyFrame, EmptyLabel, StatsBar, PublishPanel, notify
local CREATOR_STORE_SEARCH = {
    "https://apis.roblox.com/toolbox-service/v1/marketplace/10",
    "https://apis.roproxy.com/toolbox-service/v1/marketplace/10",
    "https://apis.rotunnel.com/toolbox-service/v1/marketplace/10"
}

local function searchCreatorModels(keyword, pageNumber)
    keyword = tostring(keyword or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if keyword == "" then return false, "Masukkan nama model yang ingin dicari." end
    pageNumber = math.max(0, tonumber(pageNumber) or 0)

    local query = "?limit=30&pageNumber=" .. tostring(pageNumber)
        .. "&keyword=" .. HttpService:UrlEncode(keyword)
        .. "&includeOnlyVerifiedCreators=false"

    local lastError = "Tidak ada respons dari Creator Store."
    for _, base in ipairs(CREATOR_STORE_SEARCH) do
        local body, status = httpRequest(base .. query, "GET")
        if body and (not status or (status >= 200 and status < 300)) then
            local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
            if ok and type(data) == "table" and type(data.data) == "table" then
                local results = {}
                for _, item in ipairs(data.data) do
                    local id = tonumber(item.id or item.assetId or item.AssetId)
                    if id then
                        table.insert(results, {
                            id = id,
                            name = tostring(item.name or item.Name or ("Model " .. id)),
                            creator = tostring(item.creatorName or item.CreatorName or item.creator or "Creator Store")
                        })
                    end
                end
                return true, results, data.nextPageCursor
            end
            lastError = "Format respons Creator Store tidak dikenali."
        elseif status then
            lastError = "Creator Store HTTP " .. tostring(status)
        end
    end
    return false, lastError
end

local function clearScrollCards()
    for _, c in ipairs(Scroll:GetChildren()) do
        if c:IsA("Frame") and c ~= EmptyFrame then c:Destroy() end
    end
end

local function buildModelResultCard(info)
    EmptyFrame.Visible = false

    local card = Instance.new("Frame", Scroll)
    card.Size = UDim2.new(1, 0, 0, 58)
    card.BackgroundColor3 = Color3.fromRGB(24, 18, 42)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", card)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(70, 42, 100)

    local thumb = Instance.new("ImageLabel", card)
    thumb.Size = UDim2.new(0, 44, 0, 44)
    thumb.Position = UDim2.new(0, 6, 0.5, -22)
    thumb.BackgroundColor3 = Color3.fromRGB(15, 12, 28)
    thumb.BorderSizePixel = 0
    thumb.Image = "rbxthumb://type=Asset&id=" .. tostring(info.id) .. "&w=150&h=150"
    thumb.ScaleType = Enum.ScaleType.Crop
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 5)

    local name = Instance.new("TextLabel", card)
    name.Size = UDim2.new(1, -142, 0, 18)
    name.Position = UDim2.new(0, 58, 0, 7)
    name.BackgroundTransparency = 1
    name.Text = tostring(info.name)
    name.TextColor3 = Color3.fromRGB(225, 215, 240)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 9
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd

    local creator = Instance.new("TextLabel", card)
    creator.Size = UDim2.new(1, -142, 0, 13)
    creator.Position = UDim2.new(0, 58, 0, 26)
    creator.BackgroundTransparency = 1
    creator.Text = "ID: " .. tostring(info.id) .. "  •  " .. tostring(info.creator)
    creator.TextColor3 = Color3.fromRGB(135, 115, 165)
    creator.Font = Enum.Font.Gotham
    creator.TextSize = 7
    creator.TextXAlignment = Enum.TextXAlignment.Left
    creator.TextTruncate = Enum.TextTruncate.AtEnd

    local insert = Instance.new("TextButton", card)
    insert.Size = UDim2.new(0, 66, 0, 26)
    insert.Position = UDim2.new(1, -72, 0.5, -13)
    insert.BackgroundColor3 = Color3.fromRGB(18, 58, 27)
    insert.BorderSizePixel = 0
    insert.Text = "INSERT"
    insert.TextColor3 = Color3.fromRGB(190, 255, 180)
    insert.Font = Enum.Font.GothamBold
    insert.TextSize = 8
    Instance.new("UICorner", insert).CornerRadius = UDim.new(0, 5)

    insert.MouseButton1Click:Connect(function()
        if insert.Text == "LOAD..." then return end
        insert.Text = "LOAD..."
        task.spawn(function()
            local ok, msg = insertToolboxModel(tostring(info.id))
            if ok then
                insert.Text = "DONE"
                insert.BackgroundColor3 = Color3.fromRGB(70, 150, 78)
                notify("Creator Store", tostring(info.name) .. " berhasil diinsert.", Color3.fromRGB(120, 230, 135))
            else
                insert.Text = "FAIL"
                insert.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
                notify("Insert Gagal", tostring(msg), Color3.fromRGB(240, 90, 90))
            end
            task.wait(1.5)
            insert.Text = "INSERT"
            insert.BackgroundColor3 = Color3.fromRGB(18, 58, 27)
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
HackerAtmosphere.BackgroundColor3 = Color3.fromRGB(12, 10, 24)
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
-- LOADING SCREEN (HACKER MATRIX RAIN + NANG RBXM CENTER TEXT)
-- ═══════════════════════════════════════════════════════════════════════
local LoadingScreen = Instance.new("Frame", UI)
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
LoadingScreen.Position = UDim2.new(0, 0, 0, 0)
LoadingScreen.BackgroundColor3 = Color3.fromRGB(7, 6, 14)
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex = 999

-- Matrix rain canvas
local MatrixCanvas = Instance.new("Frame", LoadingScreen)
MatrixCanvas.Name = "MatrixCanvas"
MatrixCanvas.Size = UDim2.new(1, 0, 1, 0)
MatrixCanvas.BackgroundTransparency = 1
MatrixCanvas.ZIndex = 999

-- Characters used for matrix rain
local matrixChars = {"0","1","0","1","A","B","C","D","E","F","$","#","%","@","!","&","*","X","Z","0","1"}

-- Spawn multiple falling text columns
local COLUMN_COUNT = 18
local columns = {}

for col = 1, COLUMN_COUNT do
    local xPos = (col - 1) / COLUMN_COUNT
    local columnFrame = Instance.new("Frame", MatrixCanvas)
    columnFrame.Size = UDim2.new(1 / COLUMN_COUNT, 0, 1, 0)
    columnFrame.Position = UDim2.new(xPos, 0, 0, 0)
    columnFrame.BackgroundTransparency = 1
    columnFrame.ZIndex = 999
    columnFrame.ClipsDescendants = true

    -- Each column has a stream of characters
    local streamLength = math.random(6, 16)
    local charLabels = {}
    for row = 1, streamLength do
        local charLabel = Instance.new("TextLabel", columnFrame)
        charLabel.Size = UDim2.new(1, 0, 0, 18)
        charLabel.Position = UDim2.new(0, 0, 0, (row - 1) * 18)
        charLabel.BackgroundTransparency = 1
        charLabel.Font = Enum.Font.Code
        charLabel.TextSize = 14
        charLabel.TextXAlignment = Enum.TextXAlignment.Center
        -- Head char is bright green, tail fades
        if row == 1 then
            charLabel.TextColor3 = Color3.fromRGB(240, 225, 255)
        elseif row <= 3 then
            charLabel.TextColor3 = Color3.fromRGB(180, 95, 255)
        elseif row <= 6 then
            charLabel.TextColor3 = Color3.fromRGB(130, 65, 210)
        else
            charLabel.TextColor3 = Color3.fromRGB(75, 40, 125)
        end
        charLabel.Text = matrixChars[math.random(1, #matrixChars)]
        charLabel.ZIndex = 999
        table.insert(charLabels, charLabel)
    end

    -- Randomize start offset and speed
    local startY = math.random(-800, -100)
    local speed = math.random(180, 420)
    local currentY = startY

    table.insert(columns, {
        frame = columnFrame,
        labels = charLabels,
        y = currentY,
        speed = speed,
        streamLength = streamLength,
        charTimer = 0,
        charInterval = math.random(3, 8) * 0.05
    })
end

-- CENTER: NANG RBXM text - no stroke, no background, text only + decorative elements
local CenterContainer = Instance.new("Frame", LoadingScreen)
CenterContainer.Size = UDim2.new(0, 500, 0, 220)
CenterContainer.Position = UDim2.new(0.5, -250, 0.5, -110)
CenterContainer.BackgroundTransparency = 1
CenterContainer.ZIndex = 1001

-- Top decorative line
local TopLine = Instance.new("TextLabel", CenterContainer)
TopLine.Size = UDim2.new(1, 0, 0, 20)
TopLine.Position = UDim2.new(0, 0, 0, 0)
TopLine.BackgroundTransparency = 1
TopLine.Text = "── ◈ ────────────────────── ◈ ──"
TopLine.TextColor3 = Color3.fromRGB(175, 95, 255)
TopLine.Font = Enum.Font.Code
TopLine.TextSize = 13
TopLine.ZIndex = 1001

-- Hacker terminal boot marker
local BootMarker = Instance.new("TextLabel", CenterContainer)
BootMarker.Size = UDim2.new(1, 0, 0, 38)
BootMarker.Position = UDim2.new(0, 0, 0, 22)
BootMarker.BackgroundTransparency = 1
BootMarker.Text = "[ SECURE BOOT // NANG RBXM ]"
BootMarker.TextColor3 = Color3.fromRGB(215, 180, 255)
BootMarker.Font = Enum.Font.Code
BootMarker.TextSize = 12
BootMarker.ZIndex = 1001

-- Main NANG RBXM text - GothamBold, no stroke
local KingText = Instance.new("TextLabel", CenterContainer)
KingText.Size = UDim2.new(1, 0, 0, 62)
KingText.Position = UDim2.new(0, 0, 0, 62)
KingText.BackgroundTransparency = 1
KingText.Text = "NANG RBXM"
KingText.TextColor3 = Color3.fromRGB(195, 105, 255)
KingText.Font = Enum.Font.GothamBold
KingText.TextSize = 54
KingText.ZIndex = 1001

-- Tagline below
local TagLine = Instance.new("TextLabel", CenterContainer)
TagLine.Size = UDim2.new(1, 0, 0, 22)
TagLine.Position = UDim2.new(0, 0, 0, 126)
TagLine.BackgroundTransparency = 1
TagLine.Text = "[ RBXM IMPORTER SYSTEM READY ]"
TagLine.TextColor3 = Color3.fromRGB(145, 75, 220)
TagLine.Font = Enum.Font.Code
TagLine.TextSize = 13
TagLine.ZIndex = 1001

-- Progress dots / loading indicator
local LoadDots = Instance.new("TextLabel", CenterContainer)
LoadDots.Size = UDim2.new(1, 0, 0, 20)
LoadDots.Position = UDim2.new(0, 0, 0, 152)
LoadDots.BackgroundTransparency = 1
LoadDots.Text = "loading . . ."
LoadDots.TextColor3 = Color3.fromRGB(110, 55, 175)
LoadDots.Font = Enum.Font.Code
LoadDots.TextSize = 12
LoadDots.ZIndex = 1001

-- Bottom decorative line
local BotLine = Instance.new("TextLabel", CenterContainer)
BotLine.Size = UDim2.new(1, 0, 0, 20)
BotLine.Position = UDim2.new(0, 0, 0, 196)
BotLine.BackgroundTransparency = 1
BotLine.Text = "── ◈ ────────────────────── ◈ ──"
BotLine.TextColor3 = Color3.fromRGB(175, 95, 255)
BotLine.Font = Enum.Font.Code
BotLine.TextSize = 13
BotLine.ZIndex = 1001

-- Animate matrix rain + loading dots in a single loop
local loadingActive = true
local dotStates = {"loading .     ", "loading . .   ", "loading . . . "}
local dotIndex = 0

local matrixConnection
matrixConnection = RunService.RenderStepped:Connect(function(dt)
    if not loadingActive then
        matrixConnection:Disconnect()
        return
    end

    -- Update matrix columns
    for _, col in ipairs(columns) do
        col.y = col.y + col.speed * dt
        -- Reposition frame
        col.frame.Position = UDim2.new(col.frame.Position.X.Scale, 0, 0, col.y)
        -- Reset when fully off bottom
        if col.y > 700 + col.streamLength * 18 then
            col.y = math.random(-600, -80)
            col.speed = math.random(180, 420)
        end
        -- Randomize characters periodically
        col.charTimer = col.charTimer + dt
        if col.charTimer >= col.charInterval then
            col.charTimer = 0
            col.charInterval = math.random(3, 8) * 0.05
            for _, lbl in ipairs(col.labels) do
                lbl.Text = matrixChars[math.random(1, #matrixChars)]
            end
        end
    end
end)

-- Loading dot animation + pulse on NANG RBXM text
task.spawn(function()
    local pulseUp = true
    local r, g, b = 0, 255, 70
    local tick = 0
    while loadingActive do
        task.wait(0.35)
        dotIndex = (dotIndex % 3) + 1
        LoadDots.Text = dotStates[dotIndex]
        -- Pulse green hue on main text
        tick = tick + 1
        if tick % 2 == 0 then
            KingText.TextColor3 = Color3.fromRGB(195, 105, 255)
        else
            KingText.TextColor3 = Color3.fromRGB(225, 165, 255)
        end
    end
end)

-- Auto-dismiss loading screen after 2.8 seconds
task.spawn(function()
    task.wait(2.8)
    loadingActive = false
    -- Fade out loading screen
    for i = 1, 20 do
        LoadingScreen.BackgroundTransparency = i / 20
        for _, obj in ipairs(LoadingScreen:GetDescendants()) do
            if obj:IsA("TextLabel") then
                obj.TextTransparency = i / 20
            end
        end
        task.wait(0.025)
    end
    LoadingScreen:Destroy()
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
ToggleFrame.BackgroundColor3 = Color3.fromRGB(18, 14, 35)
ToggleFrame.BackgroundTransparency = 0.08
ToggleFrame.BorderSizePixel = 0
ToggleFrame.Active = true

local ToggleCorner = Instance.new("UICorner", ToggleFrame)
ToggleCorner.CornerRadius = UDim.new(0, 10)

local ToggleGrad = Instance.new("UIGradient", ToggleFrame)
ToggleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 24, 80)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(155, 75, 230)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 10, 30))
})
ToggleGrad.Rotation = 45
registerGradientAnimation(ToggleGrad, 40, "rotate")

local ToggleStroke = Instance.new("UIStroke", ToggleFrame)
ToggleStroke.Thickness = 1.2
ToggleStroke.Color = Color3.fromRGB(215, 180, 255)
ToggleStroke.Transparency = 0.18

local ToggleIcon = Instance.new("ImageLabel", ToggleFrame)
ToggleIcon.Size = UDim2.new(0, 20, 0, 20)
ToggleIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
ToggleIcon.BackgroundTransparency = 1
ToggleIcon.Image = ICONS.CHEVRON_RIGHT
ToggleIcon.ImageColor3 = Color3.fromRGB(245, 235, 255)

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
Main.Size = UDim2.new(0, 320, 0, 430)
Main.Position = UDim2.new(0.5, -160, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(12, 10, 24)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Visible = true

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 1.2
MainStroke.Color = Color3.fromRGB(155, 90, 225)
MainStroke.Transparency = 0.2

-- TITLE BAR WITH VECTOR PACKAGE ICON
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 18, 52)
TitleBar.BorderSizePixel = 0
TitleBar.ClipsDescendants = true

-- Round the upper panel corners so the header matches the rounded body.
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local TitleGrad = Instance.new("UIGradient", TitleBar)
TitleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 10, 24)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 40, 140)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 14, 45))
})
registerGradientAnimation(TitleGrad, 0.8, "shift")

local TitleIcon = Instance.new("ImageLabel", TitleBar)
TitleIcon.Size = UDim2.new(0, 18, 0, 18)
TitleIcon.Position = UDim2.new(0, 10, 0.5, -9)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Image = ICONS.PACKAGE
TitleIcon.ImageColor3 = Color3.fromRGB(230, 210, 255)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -90, 1, 0)
TitleText.Position = UDim2.new(0, 34, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "NANG RBXM  •  IMPORTER + TOOLBOX"
TitleText.TextColor3 = Color3.fromRGB(245, 235, 255)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 12
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON WITH CLEAR X ICON
local CloseBtn = Instance.new("Frame", TitleBar)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 22, 60)
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

local CloseIcon = Instance.new("TextLabel", CloseBtn)
CloseIcon.Size = UDim2.new(0, 12, 0, 12)
CloseIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
CloseIcon.BackgroundTransparency = 1
CloseIcon.Text = "X"
CloseIcon.TextColor3 = Color3.fromRGB(225, 205, 255)
CloseIcon.Font = Enum.Font.GothamBold
CloseIcon.TextSize = 12
CloseIcon.TextXAlignment = Enum.TextXAlignment.Center
CloseIcon.TextYAlignment = Enum.TextYAlignment.Center

local CloseClick = Instance.new("TextButton", CloseBtn)
CloseClick.Size = UDim2.new(1, 0, 1, 0)
CloseClick.BackgroundTransparency = 1
CloseClick.Text = ""

-- MINIMIZE BUTTON WITH VECTOR MINIMIZE ICON
local MinBtn = Instance.new("Frame", TitleBar)
MinBtn.Size = UDim2.new(0, 22, 0, 22)
MinBtn.Position = UDim2.new(1, -54, 0.5, -11)
MinBtn.BackgroundColor3 = Color3.fromRGB(35, 22, 60)
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

local MinIcon = Instance.new("ImageLabel", MinBtn)
MinIcon.Size = UDim2.new(0, 12, 0, 12)
MinIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
MinIcon.BackgroundTransparency = 1
MinIcon.Image = ICONS.MINIMIZE
MinIcon.ImageColor3 = Color3.fromRGB(225, 205, 255)

local MinClick = Instance.new("TextButton", MinBtn)
MinClick.Size = UDim2.new(1, 0, 1, 0)
MinClick.BackgroundTransparency = 1
MinClick.Text = ""

-- Dragging System Main UI
local dragToggle, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
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

-- Toggle panel visibility - the single toggle below the Roblox menu opens/closes Main
local function toggleMain()
    Main.Visible = not Main.Visible
    ToggleIcon.Image = Main.Visible and ICONS.CHEVRON_RIGHT or ICONS.CHEVRON_LEFT
end

ToggleBtn.MouseButton1Click:Connect(toggleMain)

-- CONTENT AREA
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -16, 1, -160)
Content.Position = UDim2.new(0, 8, 0, 78)
Content.BackgroundColor3 = Color3.fromRGB(18, 14, 34)
Content.BorderSizePixel = 0
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

local ContentStroke = Instance.new("UIStroke", Content)
ContentStroke.Thickness = 1
ContentStroke.Color = Color3.fromRGB(70, 40, 105)

-- ================================================================
-- MAIN NAVIGATION: RBXM / TOOLBOX / PUBLISH
-- Semua fitur berada dalam satu UI, tetapi dipisahkan menjadi menu.
-- ================================================================
local MenuBar = Instance.new("Frame", Main)
MenuBar.Name = "MainMenu"
MenuBar.Size = UDim2.new(1, -16, 0, 30)
MenuBar.Position = UDim2.new(0, 8, 0, 42)
MenuBar.BackgroundColor3 = Color3.fromRGB(18, 14, 34)
MenuBar.BorderSizePixel = 0
Instance.new("UICorner", MenuBar).CornerRadius = UDim.new(0, 7)

local MenuStroke = Instance.new("UIStroke", MenuBar)
MenuStroke.Thickness = 1
MenuStroke.Color = Color3.fromRGB(70, 40, 105)

local MenuLayout = Instance.new("UIListLayout", MenuBar)
MenuLayout.FillDirection = Enum.FillDirection.Horizontal
MenuLayout.Padding = UDim.new(0, 4)
MenuLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
MenuLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function makeMenuButton(label, icon)
    local b = Instance.new("TextButton", MenuBar)
    b.Size = UDim2.new(0, 91, 0, 24)
    b.BackgroundColor3 = Color3.fromRGB(27, 20, 45)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

    local i = Instance.new("ImageLabel", b)
    i.Size = UDim2.new(0, 13, 0, 13)
    i.Position = UDim2.new(0, 8, 0.5, -6)
    i.BackgroundTransparency = 1
    i.Image = icon
    i.ImageColor3 = Color3.fromRGB(160, 135, 190)

    local t = Instance.new("TextLabel", b)
    t.Size = UDim2.new(1, -27, 1, 0)
    t.Position = UDim2.new(0, 25, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = label
    t.TextColor3 = Color3.fromRGB(170, 150, 195)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 8
    t.TextXAlignment = Enum.TextXAlignment.Left

    return b, i, t
end

local MenuRBXM, MenuRBXMIcon, MenuRBXMText = makeMenuButton("RBXM", ICONS.FILE)
local MenuToolbox, MenuToolboxIcon, MenuToolboxText = makeMenuButton("TOOLBOX", ICONS.PACKAGE)
local MenuPublish, MenuPublishIcon, MenuPublishText = makeMenuButton("PUBLISH", ICONS.DOWNLOAD)

local ActiveMenu = "rbxm"

-- SCAN BUTTON WITH ANIMATED GRADIENT & VECTOR SEARCH ICON
local ScanBtn = Instance.new("Frame", Content)
ScanBtn.Size = UDim2.new(1, -12, 0, 30)
ScanBtn.Position = UDim2.new(0, 6, 0, 6)
ScanBtn.BackgroundColor3 = Color3.fromRGB(225, 205, 255)
Instance.new("UICorner", ScanBtn).CornerRadius = UDim.new(0, 6)

local ScanGrad = Instance.new("UIGradient", ScanBtn)
ScanGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 240, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(165, 90, 235)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(215, 180, 250))
})
registerGradientAnimation(ScanGrad, 50, "rotate")

local ScanIcon = Instance.new("ImageLabel", ScanBtn)
ScanIcon.Size = UDim2.new(0, 14, 0, 14)
ScanIcon.Position = UDim2.new(0.5, -48, 0.5, -7)
ScanIcon.BackgroundTransparency = 1
ScanIcon.Image = ICONS.SEARCH
ScanIcon.ImageColor3 = Color3.fromRGB(30, 18, 45)

local ScanText = Instance.new("TextLabel", ScanBtn)
ScanText.Size = UDim2.new(0, 80, 1, 0)
ScanText.Position = UDim2.new(0.5, -28, 0, 0)
ScanText.BackgroundTransparency = 1
ScanText.Text = "SCAN FILES"
ScanText.TextColor3 = Color3.fromRGB(30, 18, 45)
ScanText.Font = Enum.Font.GothamBold
ScanText.TextSize = 11
ScanText.TextXAlignment = Enum.TextXAlignment.Left

local ScanClick = Instance.new("TextButton", ScanBtn)
ScanClick.Size = UDim2.new(1, 0, 1, 0)
ScanClick.BackgroundTransparency = 1
ScanClick.Text = ""

local ToolboxBox=Instance.new("TextBox",Content)
ToolboxBox.Size=UDim2.new(1,-92,0,30)
ToolboxBox.Position=UDim2.new(0,6,0,42)
ToolboxBox.BackgroundColor3=Color3.fromRGB(25,19,45)
ToolboxBox.BorderSizePixel=0
ToolboxBox.ClearTextOnFocus=false
ToolboxBox.PlaceholderText="Toolbox Asset ID / URL..."
ToolboxBox.Text=""
ToolboxBox.TextColor3=Color3.fromRGB(225,215,240)
ToolboxBox.PlaceholderColor3=Color3.fromRGB(125,110,150)
ToolboxBox.Font=Enum.Font.Gotham
ToolboxBox.TextSize=10
Instance.new("UICorner",ToolboxBox).CornerRadius=UDim.new(0,6)

local ToolboxInsert=Instance.new("TextButton",Content)
ToolboxInsert.Size=UDim2.new(0,78,0,30)
ToolboxInsert.Position=UDim2.new(1,-84,0,42)
ToolboxInsert.BackgroundColor3=Color3.fromRGB(18,58,27)
ToolboxInsert.BorderSizePixel=0
ToolboxInsert.Text="INSERT"
ToolboxInsert.TextColor3=Color3.fromRGB(190,255,180)
ToolboxInsert.Font=Enum.Font.GothamBold
ToolboxInsert.TextSize=9
Instance.new("UICorner",ToolboxInsert).CornerRadius=UDim.new(0,6)

local SearchModelBox=Instance.new("TextBox",Content)
SearchModelBox.Size=UDim2.new(1,-92,0,30)
SearchModelBox.Position=UDim2.new(0,6,0,78)
SearchModelBox.BackgroundColor3=Color3.fromRGB(25,19,45)
SearchModelBox.BorderSizePixel=0
SearchModelBox.ClearTextOnFocus=false
SearchModelBox.PlaceholderText="Cari model di Creator Store..."
SearchModelBox.Text=""
SearchModelBox.TextColor3=Color3.fromRGB(225,215,240)
SearchModelBox.PlaceholderColor3=Color3.fromRGB(145,125,175)
SearchModelBox.Font=Enum.Font.Gotham
SearchModelBox.TextSize=10
Instance.new("UICorner",SearchModelBox).CornerRadius=UDim.new(0,6)

local SearchModelBtn=Instance.new("TextButton",Content)
SearchModelBtn.Size=UDim2.new(0,78,0,30)
SearchModelBtn.Position=UDim2.new(1,-84,0,78)
SearchModelBtn.BackgroundColor3=Color3.fromRGB(82,45,145)
SearchModelBtn.BorderSizePixel=0
SearchModelBtn.Text="CARI MODEL"
SearchModelBtn.TextColor3=Color3.fromRGB(245,235,255)
SearchModelBtn.Font=Enum.Font.GothamBold
SearchModelBtn.TextSize=8
Instance.new("UICorner",SearchModelBtn).CornerRadius=UDim.new(0,6)

local ToolboxHint=Instance.new("TextLabel",Content)
ToolboxHint.Size=UDim2.new(1,-12,0,16)
ToolboxHint.Position=UDim2.new(0,6,0,112)
ToolboxHint.BackgroundTransparency=1
ToolboxHint.Text="CREATOR STORE  •  Cari model berdasarkan nama lalu tekan INSERT"
ToolboxHint.TextColor3=Color3.fromRGB(145,120,175)
ToolboxHint.Font=Enum.Font.Gotham
ToolboxHint.TextSize=7
ToolboxHint.TextXAlignment=Enum.TextXAlignment.Left


local function styleMenuButton(button, icon, label, active)
    if active then
        button.BackgroundColor3 = Color3.fromRGB(82, 45, 145)
        icon.ImageColor3 = Color3.fromRGB(245, 235, 255)
        label.TextColor3 = Color3.fromRGB(250, 245, 255)
    else
        button.BackgroundColor3 = Color3.fromRGB(27, 20, 45)
        icon.ImageColor3 = Color3.fromRGB(160, 135, 190)
        label.TextColor3 = Color3.fromRGB(170, 150, 195)
    end
end

local function showMenu(menu)
    ActiveMenu = menu

    local isRBXM = menu == "rbxm"
    local isToolbox = menu == "toolbox"
    local isPublish = menu == "publish"

    -- Main content
    Content.Visible = not isPublish
    StatsBar.Visible = not isPublish

    -- RBXM menu
    ScanBtn.Visible = isRBXM

    -- Toolbox / Creator Store menu
    ToolboxBox.Visible = isToolbox
    ToolboxInsert.Visible = isToolbox
    SearchModelBox.Visible = isToolbox
    SearchModelBtn.Visible = isToolbox
    ToolboxHint.Visible = isToolbox

    -- Shared result list
    if isRBXM then
        Scroll.Position = UDim2.new(0, 6, 0, 42)
        Scroll.Size = UDim2.new(1, -12, 1, -48)
        EmptyLabel.Text = "Belum ada file.\nTekan 'SCAN FILES' untuk mencari RBXM/RBXL."
    elseif isToolbox then
        Scroll.Position = UDim2.new(0, 6, 0, 132)
        Scroll.Size = UDim2.new(1, -12, 1, -138)
        EmptyLabel.Text = "Belum ada hasil.\nCari model di Creator Store atau gunakan Asset ID."
    end

    styleMenuButton(MenuRBXM, MenuRBXMIcon, MenuRBXMText, isRBXM)
    styleMenuButton(MenuToolbox, MenuToolboxIcon, MenuToolboxText, isToolbox)
    styleMenuButton(MenuPublish, MenuPublishIcon, MenuPublishText, isPublish)

    -- Publish memakai panel publish yang sama, tetapi dipanggil dari tab utama.
    if PublishPanel then
        PublishPanel.Visible = isPublish
        if isPublish then
            PublishPanel.ZIndex = 50
        end
    end
end

MenuRBXM.MouseButton1Click:Connect(function()
    showMenu("rbxm")
end)

MenuToolbox.MouseButton1Click:Connect(function()
    showMenu("toolbox")
end)

MenuPublish.MouseButton1Click:Connect(function()
    showMenu("publish")
end)

-- SCROLL LIST
Scroll = Instance.new("ScrollingFrame", Content)
Scroll.Size = UDim2.new(1, -12, 1, -136)
Scroll.Position = UDim2.new(0, 6, 0, 132)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(160, 95, 225)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- EMPTY STATE FRAME WITH VECTOR FOLDER ICON
EmptyFrame = Instance.new("Frame", Scroll)
EmptyFrame.Size = UDim2.new(1, 0, 0, 100)
EmptyFrame.BackgroundTransparency = 1

local EmptyIcon = Instance.new("ImageLabel", EmptyFrame)
EmptyIcon.Size = UDim2.new(0, 26, 0, 26)
EmptyIcon.Position = UDim2.new(0.5, -13, 0, 16)
EmptyIcon.BackgroundTransparency = 1
EmptyIcon.Image = ICONS.FOLDER
EmptyIcon.ImageColor3 = Color3.fromRGB(170, 100, 235)

EmptyLabel = Instance.new("TextLabel", EmptyFrame)
EmptyLabel.Size = UDim2.new(1, -20, 0, 36)
EmptyLabel.Position = UDim2.new(0, 10, 0, 48)
EmptyLabel.BackgroundTransparency = 1
EmptyLabel.Text = "Belum ada hasil.\nCari model di Creator Store atau tekan 'SCAN FILES'."
EmptyLabel.TextColor3 = Color3.fromRGB(170, 150, 195)
EmptyLabel.Font = Enum.Font.Gotham
EmptyLabel.TextSize = 10
EmptyLabel.TextWrapped = true

-- STATS BAR
StatsBar = Instance.new("Frame", Main)
StatsBar.Size = UDim2.new(1, -16, 0, 22)
StatsBar.Position = UDim2.new(0, 8, 1, -26)
StatsBar.BackgroundColor3 = Color3.fromRGB(18, 14, 34)
StatsBar.BorderSizePixel = 0
Instance.new("UICorner", StatsBar).CornerRadius = UDim.new(0, 5)

local StatsText = Instance.new("TextLabel", StatsBar)
StatsText.Size = UDim2.new(1, -10, 1, 0)
StatsText.Position = UDim2.new(0, 6, 0, 0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "Status: Ready  |  Files: 0"
StatsText.TextColor3 = Color3.fromRGB(190, 160, 225)
StatsText.Font = Enum.Font.Gotham
StatsText.TextSize = 9
StatsText.TextXAlignment = Enum.TextXAlignment.Left

-- NOTIFICATION SYSTEM WITH VECTOR BELL ICON
notify = function(title, msg, color)
    color = color or Color3.fromRGB(220, 200, 235)
    local notif = Instance.new("Frame", UI)
    notif.Size = UDim2.new(0, 220, 0, 42)
    notif.Position = UDim2.new(1, -230, 1, -55)
    notif.BackgroundColor3 = Color3.fromRGB(20, 15, 38)
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
    t.TextColor3 = Color3.fromRGB(245, 235, 255); t.Font = Enum.Font.GothamBold
    t.TextSize = 10; t.TextXAlignment = Enum.TextXAlignment.Left

    local d = Instance.new("TextLabel", notif)
    d.Size = UDim2.new(1, -12, 0, 16); d.Position = UDim2.new(0, 8, 0, 18)
    d.BackgroundTransparency = 1; d.Text = msg
    d.TextColor3 = Color3.fromRGB(165, 140, 190); d.Font = Enum.Font.Gotham
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

-- CARD BUILDER WITH VECTOR BADGES & DOWNLOAD ICON
local totalLoaded = 0

local function buildFileCard(fileInfo)
    EmptyFrame.Visible = false

    local card = Instance.new("Frame", Scroll)
    card.Size = UDim2.new(1, 0, 0, 44)
    card.BackgroundColor3 = Color3.fromRGB(24, 18, 42)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Thickness = 1
    cardStroke.Color = Color3.fromRGB(70, 42, 100)

    local isRbxl = fileInfo.ftype == "RBXL"

    local typeBadge = Instance.new("Frame", card)
    typeBadge.Size = UDim2.new(0, 48, 0, 16); typeBadge.Position = UDim2.new(0, 6, 0, 6)
    typeBadge.BackgroundColor3 = isRbxl and Color3.fromRGB(115, 220, 120) or Color3.fromRGB(43, 110, 55)
    typeBadge.BorderSizePixel = 0
    Instance.new("UICorner", typeBadge).CornerRadius = UDim.new(0, 4)

    local badgeIcon = Instance.new("ImageLabel", typeBadge)
    badgeIcon.Size = UDim2.new(0, 10, 0, 10)
    badgeIcon.Position = UDim2.new(0, 4, 0.5, -5)
    badgeIcon.BackgroundTransparency = 1
    badgeIcon.Image = isRbxl and ICONS.GAMEPAD or ICONS.FILE
    badgeIcon.ImageColor3 = Color3.fromRGB(4, 30, 13)

    local typeText = Instance.new("TextLabel", typeBadge)
    typeText.Size = UDim2.new(1, -16, 1, 0); typeText.Position = UDim2.new(0, 16, 0, 0)
    typeText.BackgroundTransparency = 1
    typeText.Text = fileInfo.ftype
    typeText.TextColor3 = Color3.fromRGB(4, 30, 13)
    typeText.Font = Enum.Font.GothamBold; typeText.TextSize = 8

    local nameLbl = Instance.new("TextLabel", card)
    nameLbl.Size = UDim2.new(1, -135, 0, 16); nameLbl.Position = UDim2.new(0, 60, 0, 6)
    nameLbl.BackgroundTransparency = 1; nameLbl.Text = fileInfo.name
    nameLbl.TextColor3 = Color3.fromRGB(210, 244, 205); nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 10; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local pathLbl = Instance.new("TextLabel", card)
    pathLbl.Size = UDim2.new(1, -135, 0, 12); pathLbl.Position = UDim2.new(0, 60, 0, 22)
    pathLbl.BackgroundTransparency = 1; pathLbl.Text = fileInfo.path
    pathLbl.TextColor3 = Color3.fromRGB(105, 170, 110); pathLbl.Font = Enum.Font.Gotham
    pathLbl.TextSize = 8; pathLbl.TextXAlignment = Enum.TextXAlignment.Left
    pathLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local insertFrame = Instance.new("Frame", card)
    insertFrame.Size = UDim2.new(0, 66, 0, 24); insertFrame.Position = UDim2.new(1, -72, 0.5, -12)
    insertFrame.BackgroundColor3 = Color3.fromRGB(18, 58, 27)
    Instance.new("UICorner", insertFrame).CornerRadius = UDim.new(0, 4)

    local btnStroke = Instance.new("UIStroke", insertFrame)
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(100, 205, 105)

    local insertIcon = Instance.new("ImageLabel", insertFrame)
    insertIcon.Size = UDim2.new(0, 10, 0, 10)
    insertIcon.Position = UDim2.new(0, 6, 0.5, -5)
    insertIcon.BackgroundTransparency = 1
    insertIcon.Image = ICONS.DOWNLOAD
    insertIcon.ImageColor3 = Color3.fromRGB(190, 255, 180)

    local insertText = Instance.new("TextLabel", insertFrame)
    insertText.Size = UDim2.new(1, -18, 1, 0); insertText.Position = UDim2.new(0, 18, 0, 0)
    insertText.BackgroundTransparency = 1; insertText.Text = "INSERT"
    insertText.TextColor3 = Color3.fromRGB(190, 255, 180)
    insertText.Font = Enum.Font.GothamBold; insertText.TextSize = 8

    local insertBtn = Instance.new("TextButton", insertFrame)
    insertBtn.Size = UDim2.new(1, 0, 1, 0)
    insertBtn.BackgroundTransparency = 1
    insertBtn.Text = ""

    insertBtn.MouseEnter:Connect(function() TweenService:Create(insertFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 100, 42)}):Play() end)
    insertBtn.MouseLeave:Connect(function() TweenService:Create(insertFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18, 58, 27)}):Play() end)

    insertBtn.MouseButton1Click:Connect(function()
        if insertText.Text == "LOADING" then return end
        insertText.Text = "LOADING"; insertIcon.Image = ICONS.REFRESH
        insertFrame.BackgroundColor3 = Color3.fromRGB(20, 76, 30)

        task.spawn(function()
            local ok, msg = loadFile(fileInfo)
            if ok then
                insertText.Text = "DONE"; insertIcon.Image = ICONS.CHECK
                insertFrame.BackgroundColor3 = Color3.fromRGB(95, 220, 105)
                totalLoaded = totalLoaded + 1
                StatsText.Text = string.format("Status: Ready  |  Files: %d  |  Loaded: %d", #Scroll:GetChildren() - 1, totalLoaded)
                notify("Success", fileInfo.name .. " dimuat!", Color3.fromRGB(220, 200, 235))
            else
                insertText.Text = "FAIL"; insertIcon.Image = ICONS.ALERT
                insertFrame.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
                notify("Gagal", msg, Color3.fromRGB(220, 80, 80))
            end
            task.wait(2)
            insertText.Text = "INSERT"; insertIcon.Image = ICONS.DOWNLOAD
            insertFrame.BackgroundColor3 = Color3.fromRGB(18, 58, 27)
        end)
    end)
end


local creatorPage = 0
local creatorSearching = false

local function runCreatorSearch()
    if creatorSearching then return end
    local keyword = SearchModelBox.Text
    if tostring(keyword):gsub("%s+","") == "" then
        notify("Creator Store", "Ketik nama model terlebih dahulu.", Color3.fromRGB(240, 180, 80))
        return
    end

    creatorSearching = true
    creatorPage = 0
    SearchModelBtn.Text = "MENCARI..."
    clearScrollCards()
    EmptyFrame.Visible = true
    EmptyLabel.Text = "Mencari model di Creator Store..."

    task.spawn(function()
        local ok, results, err = searchCreatorModels(keyword, creatorPage)
        if ok then
            EmptyFrame.Visible = (#results == 0)
            if #results == 0 then
                EmptyLabel.Text = "Model tidak ditemukan.\nCoba kata kunci lain."
            else
                for _, info in ipairs(results) do
                    buildModelResultCard(info)
                end
                StatsText.Text = string.format("Status: Creator Store  |  %d model", #results)
                notify("Creator Store", #results .. " model ditemukan.", Color3.fromRGB(190, 150, 245))
            end
        else
            EmptyFrame.Visible = true
            EmptyLabel.Text = "Pencarian gagal.\n" .. tostring(err)
            notify("Creator Store Gagal", tostring(results), Color3.fromRGB(240, 90, 90))
        end
        SearchModelBtn.Text = "CARI MODEL"
        creatorSearching = false
    end)
end

SearchModelBtn.MouseButton1Click:Connect(runCreatorSearch)
SearchModelBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then runCreatorSearch() end
end)

ToolboxInsert.MouseButton1Click:Connect(function()
    if ToolboxInsert.Text=="LOAD..." then return end
    ToolboxInsert.Text="LOAD..."
    task.spawn(function()
        local ok,msg=insertToolboxModel(ToolboxBox.Text)
        if ok then notify("Toolbox","Model berhasil diinsert: "..tostring(msg),Color3.fromRGB(120,230,135)); ToolboxInsert.Text="DONE" else notify("Toolbox Gagal",tostring(msg),Color3.fromRGB(240,90,90)); ToolboxInsert.Text="FAIL" end
        task.wait(1.5)
        ToolboxInsert.Text="INSERT"
    end)
end)

-- SCAN LOGIC
ScanClick.MouseButton1Click:Connect(function()
    ScanText.Text = "SCANNING..."
    ScanIcon.Image = ICONS.REFRESH

    for _, c in ipairs(Scroll:GetChildren()) do 
        if c:IsA("Frame") and c ~= EmptyFrame then c:Destroy() end 
    end
    EmptyFrame.Visible = true
    totalLoaded = 0

    task.spawn(function()
        local foundFiles = scanAll()
        for _, f in ipairs(foundFiles) do buildFileCard(f) end

        StatsText.Text = string.format("Status: Ready  |  Files: %d", #foundFiles)
        ScanText.Text = "SCAN FILES"
        ScanIcon.Image = ICONS.SEARCH

        if #foundFiles == 0 then
            EmptyLabel.Text = "Tidak ada file RBXM/RBXL terdeteksi.\nPeriksa folder workspace executor."
        else
            notify("Scan Selesai", #foundFiles .. " file terdeteksi", Color3.fromRGB(220, 220, 230))
        end
    end)
end)


-- ═══════════════════════════════════════════════════════════════════════
-- INSTANT MAP PUBLISHER — ROBLOX OPEN CLOUD
-- Publishes an .rbxl/.rbxlx place file to an existing Universe/Place.
-- Requires a Roblox Open Cloud API key with universe-places write access.
-- ═══════════════════════════════════════════════════════════════════════
local function openCloudRequest(url, method, headers, body)
    local funcs = {
        function()
            if syn and syn.request then
                local r = syn.request({Url=url, Method=method, Headers=headers, Body=body})
                return r.Body, r.StatusCode
            end
        end,
        function()
            if request then
                local r = request({Url=url, Method=method, Headers=headers, Body=body})
                return r.Body, r.StatusCode
            end
        end,
        function()
            if http_request then
                local r = http_request({Url=url, Method=method, Headers=headers, Body=body})
                return r.Body, r.StatusCode
            end
        end,
        function()
            if fluxus and fluxus.request then
                local r = fluxus.request({Url=url, Method=method, Headers=headers, Body=body})
                return r.Body, r.StatusCode
            end
        end
    }
    for _, fn in ipairs(funcs) do
        local ok, responseBody, status = pcall(fn)
        if ok and status then
            return responseBody or "", tonumber(status) or 0
        end
    end
    return nil, 0
end

local function readExistingBinary(path)
    if not readfile then return nil end
    local ok, data = pcall(readfile, path)
    if ok and type(data) == "string" and #data > 100 then return data end
    return nil
end

local function saveCurrentPlaceBinary(path)
    -- If the executor already has a saved place file, use it first.
    local existing = readExistingBinary(path)
    if existing then return existing end
    if not saveinstance then
        return nil, "Executor tidak menyediakan saveinstance(). Masukkan path file .rbxl yang sudah ada."
    end

    local attempts = {
        function() return saveinstance({Path = path}) end,
        function() return saveinstance({path = path}) end,
        function() return saveinstance({FilePath = path}) end,
        function() return saveinstance(path) end,
    }
    for _, fn in ipairs(attempts) do
        pcall(fn)
        local data = readExistingBinary(path)
        if data then return data end
    end
    return nil, "saveinstance() dipanggil tetapi file .rbxl tidak berhasil dibuat."
end

local function resolveUniverseRootPlace(apiKey, universeId)
    -- The public games endpoint exposes rootPlaceId from a Universe ID,
    -- so the user does not need to enter a separate Place ID.
    local url = "https://games.roblox.com/v1/games?universeIds=" .. tostring(universeId)
    local body, status = openCloudRequest(url, "GET", { ["Accept"] = "application/json" }, nil)
    if not body or status < 200 or status >= 300 then
        return nil, nil, "Tidak bisa mengambil Root Place ID. HTTP " .. tostring(status)
    end
    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(data) ~= "table" or type(data.data) ~= "table" or not data.data[1] then
        return nil, nil, "Respons Universe tidak valid."
    end
    local info = data.data[1]
    local rootPlaceId = tostring(info.rootPlaceId or ""):match("%d+")
    local universeName = tostring(info.name or "")
    if not rootPlaceId then
        return nil, universeName, "Root Place ID tidak ditemukan untuk Universe tersebut."
    end
    return rootPlaceId, universeName, nil
end

local function publishPlaceBinary(apiKey, universeId, placeId, placeBytes)
    local url = "https://apis.roblox.com/universes/v1/" .. tostring(universeId)
        .. "/places/" .. tostring(placeId) .. "/versions?versionType=Published"
    local headers = {
        ["x-api-key"] = tostring(apiKey),
        ["Content-Type"] = "application/octet-stream",
        ["Accept"] = "application/json"
    }
    return openCloudRequest(url, "POST", headers, placeBytes)
end

local function updateUniverseDisplayName(apiKey, universeId, mapName)
    if tostring(mapName or ""):gsub("%s+", "") == "" then return true, 204, "Nama dilewati" end
    local url = "https://apis.roblox.com/cloud/v2/universes/" .. tostring(universeId)
    local headers = {
        ["x-api-key"] = tostring(apiKey),
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json"
    }
    local body = HttpService:JSONEncode({displayName = tostring(mapName)})
    local response, status = openCloudRequest(url, "PATCH", headers, body)
    if status >= 200 and status < 300 then
        return true, status, response
    end
    return false, status, response
end

-- ═══════════════════════════════════════════════════════════════════════
-- CLEAN INSTANT MAP PUBLISHER UI
-- Methods:
--   1) MAP SAAT INI   -> auto-detect GameId/PlaceId
--   2) MAP KOMUNITAS  -> enter Universe ID, Root Place is resolved automatically
-- ═══════════════════════════════════════════════════════════════════════
local PublishOpenBtn = Instance.new("TextButton", TitleBar)
PublishOpenBtn.Size = UDim2.new(0, 42, 0, 22)
PublishOpenBtn.Position = UDim2.new(1, -104, 0.5, -11)
PublishOpenBtn.BackgroundColor3 = Color3.fromRGB(55, 32, 95)
PublishOpenBtn.BorderSizePixel = 0
PublishOpenBtn.Text = "PUB"
PublishOpenBtn.TextColor3 = Color3.fromRGB(230, 210, 255)
PublishOpenBtn.Font = Enum.Font.GothamBold
PublishOpenBtn.TextSize = 8
Instance.new("UICorner", PublishOpenBtn).CornerRadius = UDim.new(0, 5)
PublishOpenBtn.Visible = false

PublishPanel = Instance.new("Frame", UI)
PublishPanel.Name = "InstantPublishPanel"
PublishPanel.Size = UDim2.new(0, 330, 0, 430)
PublishPanel.Position = UDim2.new(0.5, -165, 0.5, -215)
PublishPanel.BackgroundColor3 = Color3.fromRGB(12, 10, 24)
PublishPanel.BorderSizePixel = 0
PublishPanel.Visible = false
PublishPanel.ZIndex = 50
Instance.new("UICorner", PublishPanel).CornerRadius = UDim.new(0, 12)
local ppStroke = Instance.new("UIStroke", PublishPanel)
ppStroke.Thickness = 1.2
ppStroke.Color = Color3.fromRGB(155, 90, 225)

local ppTitle = Instance.new("TextLabel", PublishPanel)
ppTitle.Size = UDim2.new(1, -60, 0, 32)
ppTitle.Position = UDim2.new(0, 14, 0, 7)
ppTitle.BackgroundTransparency = 1
ppTitle.Text = "INSTANT MAP PUBLISH"
ppTitle.TextColor3 = Color3.fromRGB(245, 235, 255)
ppTitle.Font = Enum.Font.GothamBold
ppTitle.TextSize = 12
ppTitle.TextXAlignment = Enum.TextXAlignment.Left
ppTitle.ZIndex = 51

local ppSub = Instance.new("TextLabel", PublishPanel)
ppSub.Size = UDim2.new(1, -28, 0, 18)
ppSub.Position = UDim2.new(0, 14, 0, 34)
ppSub.BackgroundTransparency = 1
ppSub.Text = "Pilih metode publish yang kamu inginkan"
ppSub.TextColor3 = Color3.fromRGB(140, 125, 165)
ppSub.Font = Enum.Font.Gotham
ppSub.TextSize = 8
ppSub.TextXAlignment = Enum.TextXAlignment.Left
ppSub.ZIndex = 51

local ppClose = Instance.new("TextButton", PublishPanel)
ppClose.Size = UDim2.new(0, 25, 0, 25)
ppClose.Position = UDim2.new(1, -34, 0, 7)
ppClose.BackgroundColor3 = Color3.fromRGB(35, 22, 60)
ppClose.BorderSizePixel = 0
ppClose.Text = "X"
ppClose.TextColor3 = Color3.fromRGB(225, 205, 255)
ppClose.Font = Enum.Font.GothamBold
ppClose.TextSize = 10
ppClose.ZIndex = 51
Instance.new("UICorner", ppClose).CornerRadius = UDim.new(0, 6)

-- Method selector
local MethodLabel = Instance.new("TextLabel", PublishPanel)
MethodLabel.Size = UDim2.new(1, -28, 0, 18)
MethodLabel.Position = UDim2.new(0, 14, 0, 60)
MethodLabel.BackgroundTransparency = 1
MethodLabel.Text = "METODE PUBLISH"
MethodLabel.TextColor3 = Color3.fromRGB(170, 150, 195)
MethodLabel.Font = Enum.Font.GothamBold
MethodLabel.TextSize = 8
MethodLabel.TextXAlignment = Enum.TextXAlignment.Left
MethodLabel.ZIndex = 51

local function methodButton(text, x)
    local b = Instance.new("TextButton", PublishPanel)
    b.Size = UDim2.new(0.5, -18, 0, 32)
    b.Position = UDim2.new(x, 12, 0, 80)
    b.BackgroundColor3 = Color3.fromRGB(27, 20, 45)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(165, 150, 185)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 8
    b.ZIndex = 51
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local CurrentMethodBtn = methodButton("MAP SAAT INI", 0)
local CommunityMethodBtn = methodButton("MAP KOMUNITAS", 0.5)

local PublishApiKey
-- Local helper is defined here so the complete UI is self-contained.
local function makePublishBox2(parent, y, placeholder, height)
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(1, -28, 0, height or 30)
    box.Position = UDim2.new(0, 14, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(25, 19, 45)
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(225, 215, 240)
    box.PlaceholderColor3 = Color3.fromRGB(125, 110, 150)
    box.Font = Enum.Font.Gotham
    box.TextSize = 9
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ZIndex = 51
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", box)
    stroke.Thickness = 0.7
    stroke.Color = Color3.fromRGB(58, 43, 78)
    return box
end

PublishApiKey = makePublishBox2(PublishPanel, 120, "API Key (x-api-key)", 30)
PublishApiKey.TextEditable = true

-- NANG API KEY PERSISTENCE
-- Menyimpan API Key secara lokal agar tidak hilang setelah UI/script dijalankan ulang.
-- Catatan: ini penyimpanan lokal, bukan Roblox DataStore.
local NANG_APIKEY_FILE = "NANG_PublishApiKey.txt"

local function loadNangApiKey()
    if type(readfile) ~= "function" then return "" end
    local ok, data = pcall(function() return readfile(NANG_APIKEY_FILE) end)
    if ok and type(data) == "string" then
        return data:gsub("^%s+", ""):gsub("%s+$", "")
    end
    return ""
end

local function saveNangApiKey(value)
    if type(writefile) ~= "function" then return false end
    value = tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if value == "" then return false end
    local ok = pcall(function()
        writefile(NANG_APIKEY_FILE, value)
    end)
    return ok
end

local savedNangApiKey = loadNangApiKey()
if savedNangApiKey ~= "" then
    PublishApiKey.Text = savedNangApiKey
end

PublishApiKey.FocusLost:Connect(function()
    local value = tostring(PublishApiKey.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if value ~= "" then
        saveNangApiKey(value)
    end
end)

local CurrentInfo = Instance.new("Frame", PublishPanel)
CurrentInfo.Size = UDim2.new(1, -28, 0, 104)
CurrentInfo.Position = UDim2.new(0, 14, 0, 158)
CurrentInfo.BackgroundColor3 = Color3.fromRGB(19, 15, 33)
CurrentInfo.BorderSizePixel = 0
CurrentInfo.ZIndex = 51
Instance.new("UICorner", CurrentInfo).CornerRadius = UDim.new(0, 8)

local CurrentTitle = Instance.new("TextLabel", CurrentInfo)
CurrentTitle.Size = UDim2.new(1, -20, 0, 20)
CurrentTitle.Position = UDim2.new(0, 10, 0, 8)
CurrentTitle.BackgroundTransparency = 1
CurrentTitle.Text = "MAP SAAT INI"
CurrentTitle.TextColor3 = Color3.fromRGB(200, 175, 230)
CurrentTitle.Font = Enum.Font.GothamBold
CurrentTitle.TextSize = 9
CurrentTitle.TextXAlignment = Enum.TextXAlignment.Left
CurrentTitle.ZIndex = 52

local CurrentMapText = Instance.new("TextLabel", CurrentInfo)
CurrentMapText.Size = UDim2.new(1, -20, 0, 62)
CurrentMapText.Position = UDim2.new(0, 10, 0, 30)
CurrentMapText.BackgroundTransparency = 1
CurrentMapText.TextColor3 = Color3.fromRGB(190, 180, 205)
CurrentMapText.Font = Enum.Font.Gotham
CurrentMapText.TextSize = 8
CurrentMapText.TextWrapped = true
CurrentMapText.TextXAlignment = Enum.TextXAlignment.Left
CurrentMapText.TextYAlignment = Enum.TextYAlignment.Top
CurrentMapText.ZIndex = 52

local CommunityInfo = Instance.new("Frame", PublishPanel)
CommunityInfo.Size = UDim2.new(1, -28, 0, 104)
CommunityInfo.Position = UDim2.new(0, 14, 0, 158)
CommunityInfo.BackgroundColor3 = Color3.fromRGB(19, 15, 33)
CommunityInfo.BorderSizePixel = 0
CommunityInfo.Visible = false
CommunityInfo.ZIndex = 51
Instance.new("UICorner", CommunityInfo).CornerRadius = UDim.new(0, 8)

local CommunityTitle = Instance.new("TextLabel", CommunityInfo)
CommunityTitle.Size = UDim2.new(1, -20, 0, 20)
CommunityTitle.Position = UDim2.new(0, 10, 0, 8)
CommunityTitle.BackgroundTransparency = 1
CommunityTitle.Text = "MAP KOMUNITAS"
CommunityTitle.TextColor3 = Color3.fromRGB(200, 175, 230)
CommunityTitle.Font = Enum.Font.GothamBold
CommunityTitle.TextSize = 9
CommunityTitle.TextXAlignment = Enum.TextXAlignment.Left
CommunityTitle.ZIndex = 52

local CommunityUniverse = makePublishBox2(CommunityInfo, 34, "Universe ID komunitas", 30)
local CommunityName = makePublishBox2(CommunityInfo, 68, "Nama map / experience (opsional)", 30)

local PublishPath = makePublishBox2(PublishPanel, 272, "Path file .rbxl — default: NANG_PUBLISH.rbxl", 30)
PublishPath.Text = "NANG_PUBLISH.rbxl"

local RefreshMapBtn = Instance.new("TextButton", PublishPanel)
RefreshMapBtn.Size = UDim2.new(0, 82, 0, 28)
RefreshMapBtn.Position = UDim2.new(1, -96, 0, 230)
RefreshMapBtn.BackgroundColor3 = Color3.fromRGB(31, 24, 50)
RefreshMapBtn.BorderSizePixel = 0
RefreshMapBtn.Text = "REFRESH"
RefreshMapBtn.TextColor3 = Color3.fromRGB(195, 175, 220)
RefreshMapBtn.Font = Enum.Font.GothamBold
RefreshMapBtn.TextSize = 8
RefreshMapBtn.ZIndex = 51
Instance.new("UICorner", RefreshMapBtn).CornerRadius = UDim.new(0, 6)

local PublishBtn = Instance.new("TextButton", PublishPanel)
PublishBtn.Size = UDim2.new(1, -28, 0, 36)
PublishBtn.Position = UDim2.new(0, 14, 0, 310)
PublishBtn.BackgroundColor3 = Color3.fromRGB(104, 58, 175)
PublishBtn.BorderSizePixel = 0
PublishBtn.Text = "PUBLISH MAP SAAT INI"
PublishBtn.TextColor3 = Color3.fromRGB(250, 245, 255)
PublishBtn.Font = Enum.Font.GothamBold
PublishBtn.TextSize = 9
PublishBtn.ZIndex = 51
Instance.new("UICorner", PublishBtn).CornerRadius = UDim.new(0, 7)

local PublishStatus = Instance.new("TextLabel", PublishPanel)
PublishStatus.Size = UDim2.new(1, -28, 0, 52)
PublishStatus.Position = UDim2.new(0, 14, 0, 354)
PublishStatus.BackgroundTransparency = 1
PublishStatus.Text = "Status: Ready"
PublishStatus.TextColor3 = Color3.fromRGB(175, 150, 205)
PublishStatus.Font = Enum.Font.Gotham
PublishStatus.TextSize = 8
PublishStatus.TextWrapped = true
PublishStatus.TextXAlignment = Enum.TextXAlignment.Left
PublishStatus.TextYAlignment = Enum.TextYAlignment.Top
PublishStatus.ZIndex = 51

local publishMethod = "current"
local publishing = false

-- Resolve Universe ID directly from the current Place ID when GameId is
-- unavailable/0 (common in some Studio/editor environments). Roblox exposes
-- this endpoint without requiring a user cookie.
local function resolveUniverseFromPlaceId(placeId)
    placeId = tostring(placeId or ""):match("%d+")
    if not placeId or placeId == "0" then
        return nil, "Place ID kosong."
    end

    local url = "https://apis.roblox.com/universes/v1/places/" .. placeId .. "/universe"
    local body, status = openCloudRequest(url, "GET", { ["Accept"] = "application/json" }, nil)
    if not body or status < 200 or status >= 300 then
        return nil, "Gagal mengambil Universe ID dari Place ID. HTTP " .. tostring(status or 0)
    end

    local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
    if not ok or type(data) ~= "table" then
        return nil, "Respons Universe ID tidak valid."
    end

    local uid = tonumber(data.universeId or data.UniverseId or data.id)
    if not uid or uid <= 0 then
        return nil, "Universe ID tidak ditemukan dari Place ID."
    end
    return tostring(uid), nil
end

local function _nangReadNumericMeta(root, names)
    if not root then return nil end
    local wanted = {}
    for _, n in ipairs(names) do wanted[string.lower(n)] = true end

    local function check(inst)
        if not inst then return nil end

        -- Attributes are the safest metadata channel when Studio Lite exposes them.
        for _, n in ipairs(names) do
            local ok, v = pcall(function() return inst:GetAttribute(n) end)
            if ok and v ~= nil then
                local num = tonumber(tostring(v):match("%d+"))
                if num and num > 0 then return num end
            end
        end

        -- Also support NumberValue / IntValue / StringValue metadata objects.
        for _, child in ipairs(inst:GetChildren()) do
            local lname = string.lower(child.Name)
            if wanted[lname] then
                local ok, v = pcall(function() return child.Value end)
                if ok and v ~= nil then
                    local num = tonumber(tostring(v):match("%d+"))
                    if num and num > 0 then return num end
                end
            end
        end
        return nil
    end

    local direct = check(root)
    if direct then return direct end

    -- Only inspect metadata containers. Do NOT use game.GameId/game.PlaceId here,
    -- because Studio Lite can expose its own host/template IDs.
    for _, d in ipairs(root:GetDescendants()) do
        local lname = string.lower(d.Name)
        if wanted[lname] then
            local ok, v = pcall(function()
                return d:IsA("ValueBase") and d.Value or d:GetAttribute("Value")
            end)
            if ok and v ~= nil then
                local num = tonumber(tostring(v):match("%d+"))
                if num and num > 0 then return num end
            end
        end
    end
    return nil
end

local function _nangReadMapName()
    local candidates = {
        function() return workspace:GetAttribute("MapName") end,
        function() return workspace:GetAttribute("PlaceName") end,
        function() return workspace:GetAttribute("ExperienceName") end,
        function() return game:GetAttribute("MapName") end,
        function() return game:GetAttribute("PlaceName") end,
    }
    for _, fn in ipairs(candidates) do
        local ok, v = pcall(fn)
        if ok and type(v) == "string" and v:gsub("%s+", "") ~= "" then
            return v
        end
    end
    return nil
end

local function detectCurrentMap()
    -- IMPORTANT:
    -- In Studio Lite, game.GameId/game.PlaceId may belong to Studio Lite's
    -- host/template. Never use those values as the user's target map.
    local isStudioLite = slFolder ~= nil

    local universeId, placeId
    local placeName = _nangReadMapName() or "Map Saat Ini"

    if isStudioLite then
        -- Look only for IDs explicitly exposed as metadata by Studio Lite.
        universeId = _nangReadNumericMeta(slFolder, {
            "UniverseId", "UniverseID", "GameId", "GameID", "ExperienceId",
            "ExperienceID", "TargetUniverseId", "TargetGameId"
        })
        placeId = _nangReadNumericMeta(slFolder, {
            "PlaceId", "PlaceID", "TargetPlaceId", "TargetPlaceID"
        })

        -- Some builds may expose metadata on Workspace instead.
        universeId = universeId or _nangReadNumericMeta(workspace, {
            "UniverseId", "UniverseID", "GameId", "GameID", "ExperienceId",
            "ExperienceID", "TargetUniverseId", "TargetGameId"
        })
        placeId = placeId or _nangReadNumericMeta(workspace, {
            "PlaceId", "PlaceID", "TargetPlaceId", "TargetPlaceID"
        })

        -- If Studio Lite does not expose target metadata, returning its own
        -- DataModel IDs would publish to the wrong experience. Fail safely.
        if not universeId or not placeId then
            CurrentMapText.Text =
                "Nama: " .. placeName ..
                "\nUniverse: -" ..
                "\nPlace: -" ..
                "\nStatus: Studio Lite tidak menyediakan ID map target."
            return "-", "-", placeName
        end
    else
        local placeIdNum = tonumber(game.PlaceId) or 0
        local gameIdNum = tonumber(game.GameId) or 0

        if placeIdNum > 0 then
            placeId = tostring(placeIdNum)
            pcall(function()
                local info = game:GetService("MarketplaceService"):GetProductInfo(placeIdNum)
                if type(info) == "table" and info.Name then
                    placeName = tostring(info.Name)
                end
            end)
        end

        if gameIdNum > 0 then
            universeId = tostring(gameIdNum)
        elseif placeIdNum > 0 then
            local resolved = resolveUniverseFromPlaceId(placeIdNum)
            if resolved then universeId = resolved end
        end
    end

    universeId = universeId and tostring(universeId) or "-"
    placeId = placeId and tostring(placeId) or "-"

    CurrentMapText.Text =
        "Nama: " .. placeName ..
        "\nUniverse: " .. universeId ..
        "\nPlace: " .. placeId ..
        "\nStatus: " .. ((universeId ~= "-" and placeId ~= "-") and
            "ID target berhasil dideteksi" or "ID target belum tersedia")

    return universeId, placeId, placeName
end

local function setPublishMethod(method)
    publishMethod = method
    local current = method == "current"
    CurrentInfo.Visible = current
    CommunityInfo.Visible = not current
    CurrentMethodBtn.BackgroundColor3 = current and Color3.fromRGB(104, 58, 175) or Color3.fromRGB(27, 20, 45)
    CommunityMethodBtn.BackgroundColor3 = current and Color3.fromRGB(27, 20, 45) or Color3.fromRGB(104, 58, 175)
    CurrentMethodBtn.TextColor3 = current and Color3.fromRGB(250, 245, 255) or Color3.fromRGB(165, 150, 185)
    CommunityMethodBtn.TextColor3 = current and Color3.fromRGB(165, 150, 185) or Color3.fromRGB(250, 245, 255)
    PublishBtn.Text = current and "PUBLISH MAP SAAT INI" or "PUBLISH MAP KOMUNITAS"
end

CurrentMethodBtn.MouseButton1Click:Connect(function() setPublishMethod("current") end)
CommunityMethodBtn.MouseButton1Click:Connect(function() setPublishMethod("community") end)
RefreshMapBtn.MouseButton1Click:Connect(function()
    local ok, err = pcall(detectCurrentMap)
    if ok then
        PublishStatus.Text = "Map saat ini berhasil dideteksi ulang."
        PublishStatus.TextColor3 = Color3.fromRGB(120, 210, 150)
    else
        PublishStatus.Text = "Gagal mendeteksi map: " .. tostring(err)
        PublishStatus.TextColor3 = Color3.fromRGB(240, 110, 110)
    end
end)

PublishOpenBtn.MouseButton1Click:Connect(function()
    PublishPanel.Visible = true
    PublishPanel.ZIndex = 50
    pcall(detectCurrentMap)
    setPublishMethod(publishMethod)
end)
ppClose.MouseButton1Click:Connect(function()
    PublishPanel.Visible = false
end)

PublishBtn.MouseButton1Click:Connect(function()
    if publishing then return end
    publishing = true
    PublishBtn.Text = "PUBLISHING..."
    PublishStatus.TextColor3 = Color3.fromRGB(210, 190, 240)

    task.spawn(function()
        local apiKey = tostring(PublishApiKey.Text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if apiKey ~= "" then
            saveNangApiKey(apiKey)
        end
        local universeId, placeId, mapName

        if apiKey == "" then
            PublishStatus.Text = "API Key belum diisi."
            PublishStatus.TextColor3 = Color3.fromRGB(240, 110, 110)
            PublishBtn.Text = publishMethod == "current" and "PUBLISH MAP SAAT INI" or "PUBLISH MAP KOMUNITAS"
            publishing = false
            return
        end

        if publishMethod == "current" then
            universeId, placeId, mapName = detectCurrentMap()
            if universeId == "-" or placeId == "-" then
                PublishStatus.Text = "Universe/Place ID tidak terdeteksi."
                PublishStatus.TextColor3 = Color3.fromRGB(240, 110, 110)
                PublishBtn.Text = "PUBLISH MAP SAAT INI"
                publishing = false
                return
            end
        else
            universeId = tostring(CommunityUniverse.Text or ""):match("%d+")
            mapName = tostring(CommunityName.Text or "")
            if not universeId then
                PublishStatus.Text = "Isi Universe ID map komunitas terlebih dahulu."
                PublishStatus.TextColor3 = Color3.fromRGB(240, 110, 110)
                PublishBtn.Text = "PUBLISH MAP KOMUNITAS"
                publishing = false
                return
            end
            PublishStatus.Text = "Mencari Root Place ID komunitas..."
            local rootPlace, autoName, resolveErr = resolveUniverseRootPlace(apiKey, universeId)
            if not rootPlace then
                PublishStatus.Text = tostring(resolveErr or "Root Place tidak ditemukan.")
                PublishStatus.TextColor3 = Color3.fromRGB(240, 110, 110)
                PublishBtn.Text = "PUBLISH MAP KOMUNITAS"
                publishing = false
                return
            end
            placeId = rootPlace
            if mapName:gsub("%s+", "") == "" then mapName = autoName or "" end
        end

        local filePath = tostring(PublishPath.Text or "NANG_PUBLISH.rbxl")
        if filePath:gsub("%s+", "") == "" then filePath = "NANG_PUBLISH.rbxl" end

        PublishStatus.Text = "Map: " .. tostring(mapName) .. "\nMembuat snapshot..."
        local placeBytes, saveErr = saveCurrentPlaceBinary(filePath)
        if not placeBytes then
            PublishStatus.Text = tostring(saveErr)
            PublishStatus.TextColor3 = Color3.fromRGB(240, 110, 110)
            PublishBtn.Text = publishMethod == "current" and "PUBLISH MAP SAAT INI" or "PUBLISH MAP KOMUNITAS"
            publishing = false
            return
        end

        PublishStatus.Text = "Mengunggah map ke Roblox..."
        local body, status = publishPlaceBinary(apiKey, universeId, placeId, placeBytes)
        if not status or status < 200 or status >= 300 then
            local detail = tostring(body or "Tidak ada response body")
            local okErr, errData = pcall(function() return HttpService:JSONDecode(detail) end)
            if okErr and type(errData) == "table" then
                detail = tostring(errData.message or errData.error or detail)
            end
            PublishStatus.Text = "Publish gagal. HTTP " .. tostring(status or 0) .. "\n" .. detail
            PublishStatus.TextColor3 = Color3.fromRGB(240, 110, 110)
            PublishBtn.Text = publishMethod == "current" and "PUBLISH MAP SAAT INI" or "PUBLISH MAP KOMUNITAS"
            publishing = false
            return
        end

        local version = ""
        local okJson, decoded = pcall(function() return HttpService:JSONDecode(body or "") end)
        if okJson and type(decoded) == "table" and decoded.versionNumber then
            version = " v" .. tostring(decoded.versionNumber)
        end

        -- Optional display-name update for community mode.
        local nameMsg = ""
        if publishMethod == "community" and mapName:gsub("%s+", "") ~= "" then
            local nameOk, nameStatus = updateUniverseDisplayName(apiKey, universeId, mapName)
            if nameOk then
                nameMsg = " • Nama diperbarui"
            else
                nameMsg = " • Publish sukses, nama gagal (HTTP " .. tostring(nameStatus) .. ")"
            end
        end

        PublishStatus.Text = "BERHASIL!" .. version .. nameMsg
        PublishStatus.TextColor3 = Color3.fromRGB(120, 230, 135)
        notify("Publish Berhasil", "Map berhasil dipublikasikan" .. version .. nameMsg, Color3.fromRGB(120, 230, 135))
        PublishBtn.Text = publishMethod == "current" and "PUBLISH MAP SAAT INI" or "PUBLISH MAP KOMUNITAS"
        publishing = false
    end)
end)

pcall(detectCurrentMap)
setPublishMethod("current")
showMenu("rbxm")

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
        Main.Size = UDim2.new(0, 320, 0, 36)
    else
        Content.Visible = true
        StatsBar.Visible = true
        Main.Size = UDim2.new(0, 320, 0, 430)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════
-- HOOKS (Anti-Putus Studio Lite)
-- ═══════════════════════════════════════════════════════════════════════
task.spawn(function()
    if hookmetamethod then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if not checkcaller() and method == "InvokeServer" then
                if self.Name == "GetScriptSourceServerFunction" then
                    local target = tostring(args[1])
                    for obj, src in pairs(_G.LANGZ_RAW_SOURCES) do
                        if typeof(obj) == "Instance" and (obj.ClassName .. obj.Name) == target then
                            if src and src ~= "" then return src end
                        end
                    end
                    for _, place in ipairs({workspace, ReplicatedStorage, _G.sss, _G.ss, game:GetService("StarterGui"), game:GetService("StarterPlayer"), LocalPlayer:FindFirstChild("PlayerGui"), LocalPlayer:FindFirstChild("Backpack")}) do
                        if place then
                            for _, obj in ipairs(place:GetDescendants()) do
                                if obj:IsA("LuaSourceContainer") and (obj.ClassName .. obj.Name) == target then
                                    local src = _G.LANGZ_RAW_SOURCES[obj]
                                    if src and src ~= "" then return src end
                                end
                           end
                        end
                    end
                end

                if self.Name == "SaveScriptSourceServerFunction" then
                    local target = tostring(args[1])
                    local newSource = tostring(args[2])
                    for obj, _ in pairs(_G.LANGZ_RAW_SOURCES) do
                        if typeof(obj) == "Instance" and (obj.ClassName .. obj.Name) == target then
                            _G.LANGZ_RAW_SOURCES[obj] = newSource
                            break
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
    end

    if hookfunction then
        local oldRequire
        oldRequire = hookfunction(getrenv().require or require, function(module)
            if typeof(module) == "Instance" and module:IsA("ModuleScript") then
                local src = _G.LANGZ_RAW_SOURCES[module]
                if src and src ~= "" then
                    local func, err = loadstring(src)
                    if func then 
                        local success, result = pcall(func)
                        if success then return result end
                    end
                end
            end
            return oldRequire(module)
        end)

        local oldGetObjects
        oldGetObjects = hookfunction(game.GetObjects, function(self, url, ...)
            local assetId = tostring(url):match("%d+")
            if assetId then triggerServerLoad(assetId) end
            local objects = oldGetObjects(self, url, ...)
            if objects then
                for _, obj in ipairs(objects) do
                    pcall(function() injectAllScripts(obj, {}) end)
                    pcall(function() ApplyStudioLiteProperties(obj) end)
                    pcall(function() LoadAssetsToSLServer(obj) end)
                end
            end
            return objects
        end)

        local oldLoadAsset
        oldLoadAsset = hookfunction(InsertService.LoadAsset, function(self, assetId, ...)
            triggerServerLoad(tostring(assetId))
            local obj = oldLoadAsset(self, assetId, ...)
            if obj then
                pcall(function() injectAllScripts(obj, {}) end)
                pcall(function() ApplyStudioLiteProperties(obj) end)
                pcall(function() LoadAssetsToSLServer(obj) end)
            end
            return obj
        end)
    end
end)

print("[NANG] IMPORTER LOADED")