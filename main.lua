local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Инициализация окна с системой ключей
local Window = Rayfield:CreateWindow({
   Name = "Animal Hospital Script 🐾",
   LoadingTitle = "Загрузка интерфейса...",
   LoadingSubtitle = "by Leon",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = true, -- Включаем проверку ключа
   KeySettings = {
      Title = "Система Ключей | Key System",
      Subtitle = "Введите ключ для доступа к скрипту",
      Note = "Ключ можно получить в нашем Discord канале!",
      FileName = "AnimalHospitalKey", 
      SaveKey = true, -- Запоминать ключ, чтобы не вводить каждый раз
      GrabKeyFromSite = false, 
      Key = {"ilovepigs"}, -- Сам ключ
      Actions = {
            [1] = {
                Text = "Получить ключ (Скопировать ссылку)",
                OnPressed = function()
                    -- Копируем ссылку в буфер обмена игрока
                    setclipboard("https://discord.com/channels/1524036881057189889/1524036994085425235/1524038305753202810")
                    Rayfield:Notify({
                       Title = "Успешно!",
                       Content = "Ссылка на Discord скопирована в буфер обмена!",
                       Duration = 5,
                       Image = 4483362458,
                    })
                end
            }
      }
   }
})

-- Создаем вкладку Основное
local MainTab = Window:CreateTab("Главная", 4483362458)

-- Функция изменения скорости
local SpeedSlider = MainTab:CreateSlider({
   Name = "Скорость бега (WalkSpeed)",
   Range = {16, 200},
   Increment = 1,
   Suffix = "ед.",
   CurrentValue = 16,
   Flag = "SpeedSlider", 
   Callback = function(Value)
       game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

-- Создаем вкладку Визуалы (ESP)
local VisualsTab = Window:CreateTab("Визуалы (ESP)", 4483362458)

-- Переменная для контроля работы ESP
local ESP_Enabled = false

-- Функция создания ESP на NPC
local function ApplyESP(npc)
    if not npc:FindFirstChild("HumanoidRootPart") then return end
    
    -- Проверяем, есть ли уже ESP, чтобы не создавать дубликаты
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
    textLabel.TextSize = 16
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    -- Логика определения: Аномалия или Нормальный
    -- ПРИМЕЧАНИЕ: Измени "Anomaly" на реальный признак аномальных NPC в этой игре
    -- (например, проверка имени npc.Name == "AnomalyNPC" или наличие определенного объекта внутри него)
    if string.find(string.lower(npc.Name), "anomaly") or npc:FindFirstChild("Anomaly") then
        textLabel.Text = "[⚠ АНОМАЛИЯ] " .. npc.Name
        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Красный для аномалий
    else
        textLabel.Text = "[🟢 Нормальный] " .. npc.Name
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый для обычных
    end
    
    -- Скрываем/показываем в зависимости от переключателя
    billboard.Enabled = ESP_Enabled
end

-- Включение/Выключение ESP
local ESPToggle = VisualsTab:CreateToggle({
   Name = "Включить ESP на NPC",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       ESP_Enabled = Value
       
       -- Ищем NPC в Workspace
       -- ПРИМЕЧАНИЕ: Если в игре все NPC лежат в определенной папке (например, Workspace.NPCs),
       -- лучше заменить game.Workspace:GetChildren() на эту папку.
       for _, obj in pairs(game.Workspace:GetChildren()) do
           if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= game.Players.LocalPlayer.Character then
               ApplyESP(obj)
               if obj.HumanoidRootPart:FindFirstChild("NPC_ESP_Billboard") then
                   obj.HumanoidRootPart.NPC_ESP_Billboard.Enabled = ESP_Enabled
               end
           end
       end
   end,
})

-- Автоматическое вешание ESP на новых появляющихся NPC
game.Workspace.ChildAdded:Connect(function(child)
    if ESP_Enabled and child:IsA("Model") and child:FindFirstChild("Humanoid") then
        task.wait(0.5) -- Ждем полной прогрузки модели
        ApplyESP(child)
    end
end)

Rayfield:Notify({
   Title = "Скрипт успешно запущен!",
   Content = "Приятной игры!",
   Duration = 5,
   Image = 4483362458,
})
