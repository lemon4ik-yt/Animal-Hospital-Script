-- Удаляем старый сейв ключа, чтобы окно точно появилось
pcall(function()
    if isfile and isfile("AnimalHospitalKey.txt") then
        delfile("AnimalHospitalKey.txt")
    end
end)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Инициализация окна с жесткой проверкой ключа
local Window = Rayfield:CreateWindow({
   Name = "Animal Hospital Script 🐾",
   LoadingTitle = "Загрузка интерфейса...",
   LoadingSubtitle = "by Leon",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = true, -- Система ключей включена
   KeySettings = {
      Title = "Система Ключей | Key System",
      Subtitle = "Введите ключ для доступа к скрипту",
      Note = "Ключ можно получить в нашем Discord канале!",
      FileName = "AnimalHospitalKey_🔥", -- Меняем имя файла, чтобы сбросить старые баги
      SaveKey = false, -- ОТКЛЮЧЕНО, чтобы ключ запрашивало ПРИ КАЖДОМ ЗАПУСКЕ
      GrabKeyFromSite = false, 
      Key = {"ilovepigs"}, -- Твой ключ
      Actions = {
            [1] = {
                Text = "Получить ключ",
                OnPressed = function()
                    -- Копирование ссылки в буфер обмена
                    if setclipboard then
                        setclipboard("https://discord.com/channels/1524036881057189889/1524036994085425235/1524038305753202810")
                    elseif toclipboard then
                        toclipboard("https://discord.com/channels/1524036881057189889/1524036994085425235/1524038305753202810")
                    end
                    
                    Rayfield:Notify({
                       Title = "Успешно!",
                       Content = "Ссылка на Discord скопирована! Нажмите Ctrl + V в браузере.",
                       Duration = 5,
                       Image = 4483362458,
                    })
                end
            }
      }
   }
})

-- Создаем вкладки
local MainTab = Window:CreateTab("Главная", 4483362458)
local VisualsTab = Window:CreateTab("Визуалы (ESP)", 4483362458)

-- Настройка скорости бега
local SpeedSlider = MainTab:CreateSlider({
   Name = "Скорость бега (WalkSpeed)",
   Range = {16, 150},
   Increment = 1,
   Suffix = "ед.",
   CurrentValue = 16,
   Flag = "SpeedSlider", 
   Callback = function(Value)
       pcall(function()
           game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
       end)
   end,
})

-- Переменная для ESP
local ESP_Enabled = false

-- Умная функция создания ESP
local function ApplyESP(npc)
    if not npc:IsA("Model") or not npc:FindFirstChild("HumanoidRootPart") then return end
    
    -- Очищаем старое ESP, если оно вдруг забаговалось
    if npc.HumanoidRootPart:FindFirstChild("NPC_ESP_Billboard") then
        npc.HumanoidRootPart.NPC_ESP_Billboard:Destroy()
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_ESP_Billboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 4, 0) -- Чуть выше над головой
    billboard.Parent = npc.HumanoidRootPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextSize = 20 -- Сделаем текст покрупнее
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0 -- Черная обводка текста, чтобы было видно сквозь стены
    textLabel.Parent = billboard

    -- Логика глубокой проверки на Аномалию
    local isAnomaly = false
    
    -- Проверка 1: Ищем папки конфигураций внутри NPC
    local valuesFolder = npc:FindFirstChild("Values") or npc:FindFirstChild("Configuration") or npc:FindFirstChild("Settings")
    if valuesFolder then
        for _, val in pairs(valuesFolder:GetChildren()) do
            if string.find(string.lower(val.Name), "anomaly") and (val.Value == true or val.Value == 1) then
                isAnomaly = true
            end
        end
    end

    -- Проверка 2: Прямая проверка атрибутов модели
    if npc:GetAttribute("IsAnomaly") == true or npc:GetAttribute("Anomaly") == true then
        isAnomaly = true
    end

    -- Проверка 3: Проверка по имени (на всякий случай)
    if string.find(string.lower(npc.Name), "anomaly") or string.find(string.lower(npc.Name), "fake") then
        isAnomaly = true
    end

    -- Передаем вердикт на экран
    if isAnomaly then
        textLabel.Text = "⚠️ АНОМАЛИЯ ⚠️"
        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Ярко-красный
    else
        textLabel.Text = "🟢 НОРМАЛЬНЫЙ"
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый
    end
    
    billboard.Enabled = ESP_Enabled
end

-- Функция сканирования ВСЕГО Workspace на наличие NPC
local function ScanAndApplyESP()
    for _, obj in pairs(game.Workspace:GetDescendants()) do -- Юзаем GetDescendants, если NPC лежат глубоко в папках
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= game.Players.LocalPlayer.Character then
            ApplyESP(obj)
        end
    end
end

-- Переключатель ESP в меню
local ESPToggle = VisualsTab:CreateToggle({
   Name = "Включить ESP на NPC",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       ESP_Enabled = Value
       if ESP_Enabled then
           ScanAndApplyESP()
       else
           -- Выключаем отображение
           for _, obj in pairs(game.Workspace:GetDescendants()) do
               if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj.HumanoidRootPart:FindFirstChild("NPC_ESP_Billboard") then
                   obj.HumanoidRootPart.NPC_ESP_Billboard.Enabled = false
               end
           end
       end
   end,
})

-- Слежка за новыми посетителями (когда они спавнятся или подходят к стойке)
game.Workspace.DescendantAdded:Connect(function(descendant)
    if ESP_Enabled and descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
        task.wait(0.8) -- Даем игре время выдать NPC его статус (Аномалия/Нормальный)
        ApplyESP(descendant)
    end
end)
