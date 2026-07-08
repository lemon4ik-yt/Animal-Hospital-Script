local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Инициализация окна с системой ключей
local Window = Rayfield:CreateWindow({
   Name = "Animal Hospital Script 🐾",
   LoadingTitle = "Загрузка интерфейса...",
   LoadingSubtitle = "by Leon",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = true,
   KeySettings = {
      Title = "Система Ключей | Key System",
      Subtitle = "Введите ключ для доступа к скрипту",
      Note = "Ключ можно получить в нашем Discord канале!",
      FileName = "AnimalHospitalKey", 
      SaveKey = true, 
      GrabKeyFromSite = false, 
      Key = {"ilovepigs"},
      Actions = {
            [1] = {
                Text = "Получить ключ",
                OnPressed = function()
                    -- Копирование ссылки в буфер обмена
                    setclipboard("https://discord.com/channels/1524036881057189889/1524036994085425235/1524038305753202810")
                    
                    Rayfield:Notify({
                       Title = "Успешно!",
                       Content = "Ссылка на Discord скопирована в буфер обмена! Вставьте её в браузер (Ctrl + V).",
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

-- Функция изменения скорости
local SpeedSlider = MainTab:CreateSlider({
   Name = "Скорость бега (WalkSpeed)",
   Range = {16, 200},
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

-- Переменная для контроля работы ESP
local ESP_Enabled = false

-- Функция создания ESP на NPC
local function ApplyESP(npc)
    if not npc:FindFirstChild("HumanoidRootPart") then return end
    if npc.HumanoidRootPart:FindFirstChild("NPC_ESP_Billboard") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_ESP_Billboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = npc.HumanoidRootPart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextSize = 18
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    -- Проверка на аномалию
    local isAnomaly = false
    
    -- 1. Проверка по имени или атрибутам (часто используется в таких играх)
    if string.find(string.lower(npc.Name), "anomaly") or string.find(string.lower(npc.Name), "fake") then
        isAnomaly = true
    elseif npc:GetAttribute("IsAnomaly") == true or npc:GetAttribute("Anomaly") == true then
        isAnomaly = true
    elseif npc:FindFirstChild("Configuration") and (npc.Configuration:FindFirstChild("IsAnomaly") or npc.Configuration:FindFirstChild("Anomaly")) then
        isAnomaly = true
    end

    -- Настройка внешнего вида ESP в зависимости от статуса
    if isAnomaly then
        textLabel.Text = "[⚠ АНОМАЛИЯ]"
        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Красный
    else
        textLabel.Text = "[🟢 НОРМАЛЬНЫЙ]"
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый
    end
    
    billboard.Enabled = ESP_Enabled
end

-- Обновление всех существующих NPC
local function UpdateAllNPCs()
    for _, obj in pairs(game.Workspace:GetChildren()) do
        -- Игнорируем игрока, ищем модели NPC
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= game.Players.LocalPlayer.Character then
            ApplyESP(obj)
            if obj.HumanoidRootPart:FindFirstChild("NPC_ESP_Billboard") then
                obj.HumanoidRootPart.NPC_ESP_Billboard.Enabled = ESP_Enabled
            end
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
       UpdateAllNPCs()
   end,
})

-- Следим за появлением новых NPC на стойке
game.Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") and child:FindFirstChild("Humanoid") then
        task.wait(0.5) -- Даем прогрузиться внутренним скриптам игры, чтобы определилась аномалия
        if ESP_Enabled then
            ApplyESP(child)
        end
    end
end)
