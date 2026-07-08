repeat wait() until game:IsLoaded()

-- Силовое удаление старых сохранений Orion, чтобы ключ ВСЕГДА запрашивался заново
pcall(function()
    if isfile and isfile("OrionKey.txt") then delfile("OrionKey.txt") end
    if isfile and isfile("AnimalHospital.txt") then delfile("AnimalHospital.txt") end
end)

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- Создаем окно ИГРЫ с СИСТЕМОЙ КЛЮЧЕЙ
local Window = OrionLib:MakeWindow({
    Name = "Animal Hospital Script 🐾", 
    HidePremium = false, 
    SaveConfig = false, -- Отключаем сохранение, чтобы не багался ключ
    IntroText = "Loading Animal Hospital Hub...",
    KeySystem = true, -- Включаем проверку ключа
    KeySettings = {
        Title = "🔐 Система авторизации",
        Subtitle = "Получите ключ в нашем Discord",
        Note = "Ключ находится в канале по кнопке ниже!",
        FileName = "AnimalHospitalKey_New", 
        SaveKey = false, -- Ключ запрашивается при каждом запуске!
        GrabKeyFromSite = false,
        Key = "ilovepigs" -- Твой точный ключ
    }
})

-- Добавляем кнопку получения ключа ПРЯМО в окно ввода (актуально для Orion)
OrionLib:MakeNotification({
    Name = "Нужен ключ?",
    Content = "Нажмите на кнопку 'Получить Ключ' в меню ввода, чтобы скопировать ссылку на Discord!",
    Image = "rbxassetid://4483362458",
    Time = 8
})

-- Костыль для Orion: Создаем вкладку с получением ссылки, если они уже внутри, либо кнопка сработает при создании
-- Ссылка на твой дискорд канал
local discordLink = "https://discord.com/channels/1524036881057189889/1524036994085425235/1524038305753202810"

-- Функция принудительного копирования
local function copyDiscord()
    if setclipboard then
        setclipboard(discordLink)
    elseif toclipboard then
        toclipboard(discordLink)
    end
    OrionLib:MakeNotification({
        Name = "Успешно!",
        Content = "Ссылка на Discord скопирована в буфер обмена! (Ctrl+V)",
        Image = "rbxassetid://4483362458",
        Time = 5
    })
end

-- Переопределяем встроенное действие (Orion требует клика по ссылке, но мы добавим кнопку во вкладку)
local MainTab = Window:MakeTab({
    Name = "Главная",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

MainTab:AddButton({
    Name = "🔗 Получить Ключ (Дискорд)",
    Callback = function()
        copyDiscord()
    end
})

-- Слайдер скорости
MainTab:AddSlider({
    Name = "Скорость ходьбы (WalkSpeed)",
    Min = 16,
    Max = 150,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "WS",
    Callback = function(Value)
        pcall(function()
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end)
    end    
})

-- ВКЛАДКА ВИЗУАЛЫ (ESP)
local VisualsTab = Window:MakeTab({
    Name = "Визуалы (ESP)",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local ESP_Enabled = false

-- Функция создания ESP
local function ApplyESP(npc)
    if not npc:IsA("Model") or not npc:FindFirstChild("HumanoidRootPart") then return end
    
    if npc.HumanoidRootPart:FindFirstChild("NPC_ESP_Billboard") then
        npc.HumanoidRootPart.NPC_ESP_Billboard:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_ESP_Billboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 220, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.Parent = npc.HumanoidRootPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextSize = 19
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboard

    -- Логика проверки на Аномалию в Animal Hospital
    local isAnomaly = false
    
    -- 1. Проверка по папкам конфигураций внутри NPC
    local config = npc:FindFirstChild("Values") or npc:FindFirstChild("Configuration") or npc:FindFirstChild("Settings")
    if config then
        for _, v in pairs(config:GetChildren()) do
            if string.find(string.lower(v.Name), "anomaly") and (v.Value == true or v.Value == 1) then
                isAnomaly = true
            end
        end
    end
    
    -- 2. Проверка по атрибутам или названию (если это монстр)
    if npc:GetAttribute("IsAnomaly") == true or string.find(string.lower(npc.Name), "anomaly") or string.find(string.lower(npc.Name), "monster") then
        isAnomaly = true
    end

    -- Вывод текста
    if isAnomaly then
        textLabel.Text = "⚠️ АНОМАЛИЯ ⚠️"
        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    else
        textLabel.Text = "🟢 НОРМАЛЬНЫЙ"
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    end
    
    billboard.Enabled = ESP_Enabled
end

-- Сканирование всех возможных мест появления NPC
local function ScanNPCs()
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= game.Players.LocalPlayer.Character then
            ApplyESP(obj)
        end
    end
end

-- Переключатель ESP в Orion
VisualsTab:AddToggle({
    Name = "Включить ESP на NPC",
    Default = false,
    Callback = function(Value)
        ESP_Enabled = Value
        if ESP_Enabled then
            ScanNPCs()
        else
            for _, obj in pairs(game.Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj.HumanoidRootPart:FindFirstChild("NPC_ESP_Billboard") then
                    obj.HumanoidRootPart.NPC_ESP_Billboard.Enabled = false
                end
            end
        end
    end
})

-- Авто-поиск новых существ на стойке регистрации
game.Workspace.DescendantAdded:Connect(function(descendant)
    if ESP_Enabled and descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
        task.wait(0.7)
        ApplyESP(descendant)
    end
end)

OrionLib:Init()
