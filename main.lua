repeat wait() until game:IsLoaded()

-- Скачиваем стабильный и обновленный форк Orion Library
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

-- Создаем главное окно
local Window = OrionLib:MakeWindow({
    Name = "Animal Hospital Script 🐾", 
    HidePremium = true, 
    SaveConfig = false, 
    IntroText = "Loading Animal Hospital Hub..."
})

-- Создаем вкладку для авторизации
local AuthTab = Window:MakeTab({
    Name = "🔑 Авторизация",
    Icon = "rbxassetid://4483362458",
    PremiumOnly = false
})

local discordLink = "https://discord.com/channels/1524036881057189889/1524036994085425235/1524038305753202810"
local enteredKey = "" -- Сюда сохраняется то, что ввел игрок

AuthTab:AddParagraph("Добро пожаловать!", "Для доступа к функциям скопируйте ссылку на Discord, заберите ключ и введите его ниже.")

-- Кнопка скопировать ссылку
AuthTab:AddButton({
    Name = "🔗 Получить Ключ (Скопировать ссылку)",
    Callback = function()
        if setclipboard then
            setclipboard(discordLink)
        elseif toclipboard then
            toclipboard(discordLink)
        end
        OrionLib:MakeNotification({
            Name = "Успешно!",
            Content = "Ссылка на Discord скопирована! Вставьте в браузер (Ctrl+V)",
            Image = "rbxassetid://4483362458",
            Time = 4
        })
    end
})

-- Поле ввода
AuthTab:AddTextbox({
    Name = "Введите ключ:",
    Default = "",
    TextDisappear = false,
    Callback = function(Value)
        enteredKey = Value
    end
})

-- Переменные для будущих вкладок
local MainTab = nil
local VisualsTab = nil
local ESP_Enabled = false

-- Функция разблокировки скрипта
local function UnlockScript()
    OrionLib:MakeNotification({
        Name = "Доступ разрешен!",
        Content = "Приятной игры!",
        Image = "rbxassetid://4483362458",
        Time = 4
    })

    -- Создаем вкладку "Главная"
    MainTab = Window:MakeTab({
        Name = "Главная",
        Icon = "rbxassetid://4483362458",
        PremiumOnly = false
    })

    -- Настройка скорости
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

    -- Создаем вкладку "Визуалы (ESP)"
    VisualsTab = Window:MakeTab({
        Name = "Визуалы (ESP)",
        Icon = "rbxassetid://4483362458",
        PremiumOnly = false
    })

    -- Логика ESP
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

        local isAnomaly = false
        local config = npc:FindFirstChild("Values") or npc:FindFirstChild("Configuration") or npc:FindFirstChild("Settings")
        if config then
            for _, v in pairs(config:GetChildren()) do
                if string.find(string.lower(v.Name), "anomaly") and (v.Value == true or v.Value == 1) then
                    isAnomaly = true
                end
            end
        end
        if npc:GetAttribute("IsAnomaly") == true or string.find(string.lower(npc.Name), "anomaly") or string.find(string.lower(npc.Name), "monster") then
            isAnomaly = true
        end

        if isAnomaly then
            textLabel.Text = "⚠️ АНОМАЛИЯ ⚠️"
            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            textLabel.Text = "🟢 НОРМАЛЬНЫЙ"
            textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
        billboard.Enabled = ESP_Enabled
    end

    local function ScanNPCs()
        for _, obj in pairs(game.Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= game.Players.LocalPlayer.Character then
                ApplyESP(obj)
            end
        end
    end

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

    game.Workspace.DescendantAdded:Connect(function(descendant)
        if ESP_Enabled and descendant:IsA("Model") and descendant:FindFirstChild("Humanoid") then
            task.wait(0.7)
            ApplyESP(descendant)
        end
    end)
end

-- Кнопка проверки ключа
AuthTab:AddButton({
    Name = "✅ Проверить ключ",
    Callback = function()
        if enteredKey == "ilovepigs" then
            UnlockScript()
        else
            OrionLib:MakeNotification({
                Name = "Ошибка!",
                Content = "Неверный ключ! Попробуйте еще раз.",
                Image = "rbxassetid://4483362458",
                Time = 3
            })
        end
    end
})

OrionLib:Init()
