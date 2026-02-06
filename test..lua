--[[
    ██╗     ██╗ ██████╗ ██╗   ██╗██╗██████╗      ██████╗ ██╗      █████╗ ███████╗███████╗
    ██║     ██║██╔═══██╗██║   ██║██║██╔══██╗    ██╔════╝ ██║     ██╔══██╗██╔════╝██╔════╝
    ██║     ██║██║   ██║██║   ██║██║██║  ██║    ██║  ███╗██║     ███████║███████╗███████╗
    ██║     ██║██║▄▄ ██║██║   ██║██║██║  ██║    ██║   ██║██║     ██╔══██║╚════██║╚════██║
    ███████╗██║╚██████╔╝╚██████╔╝██║██████╔╝    ╚██████╔╝███████╗██║  ██║███████║███████║
    ╚══════╝╚═╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚═════╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝
    
    Liquid Glass UI Library - v1.1.0 (Notification Integrated)
]]

local LiquidGlass = {}
LiquidGlass.__index = LiquidGlass

-- サービス
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local ScreenGuiMain = nil -- ウィンドウ作成時に初期化

-- 設定
local Settings = {
    Colors = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(150, 200, 255),
        Accent = Color3.fromRGB(100, 180, 255),
        Background = Color3.fromRGB(20, 20, 30),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Animation = {
        Speed = 0.3,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },
    Glass = {
        Transparency = 0.15,
        BlurSize = 20,
        BorderThickness = 1.5
    }
}

-- ユーティリティ関数
local function Tween(Object, Properties, Duration)
    Duration = Duration or Settings.Animation.Speed
    local tween = TweenService:Create(
        Object,
        TweenInfo.new(Duration, Settings.Animation.Style, Settings.Animation.Direction),
        Properties
    )
    tween:Play()
    return tween
end

local function AddCorner(Object, Radius)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, Radius or 12)
    Corner.Parent = Object
    return Corner
end

local function AddStroke(Object, Color, Thickness, Transparency)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color or Settings.Colors.Primary
    Stroke.Thickness = Thickness or Settings.Glass.BorderThickness
    Stroke.Transparency = Transparency or 0.5
    Stroke.Parent = Object
    return Stroke
end

local function AddGradient(Object)
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Settings.Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Settings.Colors.Secondary),
        ColorSequenceKeypoint.new(1, Settings.Colors.Accent)
    }
    Gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 0.9),
        NumberSequenceKeypoint.new(1, 0.8)
    }
    Gradient.Rotation = 45
    Gradient.Parent = Object
    return Gradient
end

local function StartLiquidAnimation(Gradient)
    local startTime = tick()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not Gradient or not Gradient.Parent then
            connection:Disconnect()
            return
        end
        local elapsed = tick() - startTime
        Gradient.Rotation = 45 + math.sin(elapsed * 0.8) * 20
        local wave = (math.sin(elapsed * 1.2) + 1) / 2
        Gradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.75 + wave * 0.1),
            NumberSequenceKeypoint.new(0.5, 0.85 + wave * 0.15),
            NumberSequenceKeypoint.new(1, 0.75 + wave * 0.1)
        }
    end)
    return connection
end

local function CreateRipple(Parent, Position)
    local Ripple = Instance.new("Frame")
    Ripple.Name = "Ripple"
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Ripple.Position = UDim2.new(0, Position.X, 0, Position.Y)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.BackgroundColor3 = Settings.Colors.Accent
    Ripple.BackgroundTransparency = 0.5
    Ripple.BorderSizePixel = 0
    Ripple.ZIndex = 100
    Ripple.Parent = Parent
    AddCorner(Ripple, 100)
    Tween(Ripple, {Size = UDim2.new(0, 300, 0, 300), BackgroundTransparency = 1}, 0.6).Completed:Connect(function()
        Ripple:Destroy()
    end)
end

-- 通知システム用コンテナ
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name = "LiquidNotify"
NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() NotifyGui.Parent = CoreGui end)
if not NotifyGui.Parent then NotifyGui.Parent = Player:WaitForChild("PlayerGui") end

local NotifyHolder = Instance.new("Frame")
NotifyHolder.Name = "NotifyHolder"
NotifyHolder.Size = UDim2.new(0, 300, 1, -40)
NotifyHolder.Position = UDim2.new(1, -310, 0, 20)
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.Parent = NotifyGui

local NotifyList = Instance.new("UIListLayout")
NotifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyList.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifyList.Padding = UDim.new(0, 10)
NotifyList.SortOrder = Enum.SortOrder.LayoutOrder
NotifyList.Parent = NotifyHolder

-- 通知関数
function LiquidGlass:Notify(Config)
    Config = Config or {}
    local Title = Config.Title or "Notification"
    local Content = Config.Content or "Message details go here."
    local Duration = Config.Duration or 5
    local Color = Config.Color or Settings.Colors.Accent

    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "Notification"
    NotifyFrame.Size = UDim2.new(0, 280, 0, 0) -- 最初は高さ0
    NotifyFrame.BackgroundColor3 = Settings.Colors.Background
    NotifyFrame.BackgroundTransparency = Settings.Glass.Transparency
    NotifyFrame.BorderSizePixel = 0
    NotifyFrame.ClipsDescendants = true
    NotifyFrame.Parent = NotifyHolder

    AddCorner(NotifyFrame, 10)
    AddStroke(NotifyFrame, Color, 1.5, 0.4)
    local Grad = AddGradient(NotifyFrame)
    StartLiquidAnimation(Grad)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 0, 30)
    TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = NotifyFrame

    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, -20, 0, 40)
    ContentLabel.Position = UDim2.new(0, 10, 0, 30)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = Content
    ContentLabel.TextColor3 = Settings.Colors.Text
    ContentLabel.TextSize = 13
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextWrapped = true
    ContentLabel.Parent = NotifyFrame

    -- 表示アニメーション
    Tween(NotifyFrame, {Size = UDim2.new(0, 280, 0, 80)}, 0.4)

    -- 自動消去
    task.delay(Duration, function()
        Tween(NotifyFrame, {Size = UDim2.new(0, 0, 0, 80), BackgroundTransparency = 1}, 0.4).Completed:Connect(function()
            NotifyFrame:Destroy()
        end)
    end)
end

-- メインウィンドウ作成
function LiquidGlass:CreateWindow(Config)
    local WindowInit = {}
    Config = Config or {}
    Config.Name = Config.Name or "Liquid Glass UI"
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LiquidGlass_" .. math.random(1000, 9999)
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end
    ScreenGuiMain = ScreenGui

    -- (ローディング画面の処理は省略せず維持)
    local LoadingScreen = Instance.new("Frame")
    LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
    LoadingScreen.BackgroundColor3 = Settings.Colors.Background
    LoadingScreen.Parent = ScreenGui
    local LoadingGrad = AddGradient(LoadingScreen)
    StartLiquidAnimation(LoadingGrad)

    local LoadingTitle = Instance.new("TextLabel")
    LoadingTitle.Size = UDim2.new(0, 400, 0, 60)
    LoadingTitle.Position = UDim2.new(0.5, -200, 0.5, -30)
    LoadingTitle.BackgroundTransparency = 1
    LoadingTitle.Text = Config.LoadingTitle or Config.Name
    LoadingTitle.TextColor3 = Settings.Colors.Text
    LoadingTitle.TextSize = 32
    LoadingTitle.Font = Enum.Font.GothamBold
    LoadingTitle.Parent = LoadingScreen

    task.wait(1.5)
    Tween(LoadingScreen, {BackgroundTransparency = 1}, 0.5).Completed:Connect(function() LoadingScreen:Destroy() end)
    Tween(LoadingTitle, {TextTransparency = 1}, 0.5)

    -- メインウィンドウ
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 550, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
    MainFrame.BackgroundColor3 = Settings.Colors.Background
    MainFrame.BackgroundTransparency = Settings.Glass.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    AddCorner(MainFrame, 16)
    AddStroke(MainFrame)
    StartLiquidAnimation(AddGradient(MainFrame))

    -- タイトルバー
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Config.Name
    TitleLabel.TextColor3 = Settings.Colors.Text
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- ドラッグ機能の実装
    local dragToggle, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragToggle = false end
    end)

    -- サイドバーとコンテンツエリア
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 140, 1, -60)
    TabContainer.Position = UDim2.new(0, 10, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -170, 1, -60)
    ContentContainer.Position = UDim2.new(0, 160, 0, 50)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    function WindowInit:CreateTab(Name, Icon)
        local TabInit = {}
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = Settings.Colors.Primary
        TabButton.BackgroundTransparency = 0.9
        TabButton.Text = " " .. (Icon or "🔘") .. " " .. Name
        TabButton.TextColor3 = Settings.Colors.SubText
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabContainer
        AddCorner(TabButton, 8)

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.ScrollBarThickness = 2
        TabPage.Parent = ContentContainer
        local PageList = Instance.new("UIListLayout", TabPage)
        PageList.Padding = UDim.new(0, 8)

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Settings.Colors.SubText end end
            TabPage.Visible = true
            TabButton.TextColor3 = Settings.Colors.Text
            CreateRipple(TabButton, Vector2.new(70, 17))
        end)

        function TabInit:CreateButton(Text, Callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -10, 0, 40)
            Btn.BackgroundColor3 = Settings.Colors.Primary
            Btn.BackgroundTransparency = 0.85
            Btn.Text = Text
            Btn.TextColor3 = Settings.Colors.Text
            Btn.Font = Enum.Font.GothamMedium
            Btn.Parent = TabPage
            AddCorner(Btn, 10)
            AddStroke(Btn, Settings.Colors.Primary, 1, 0.6)
            Btn.MouseButton1Click:Connect(function() 
                CreateRipple(Btn, Vector2.new(100, 20))
                Callback() 
            end)
        end

        function TabInit:CreateToggle(Text, Default, Callback)
            local TglFrame = Instance.new("Frame")
            TglFrame.Size = UDim2.new(1, -10, 0, 40)
            TglFrame.BackgroundColor3 = Settings.Colors.Primary
            TglFrame.BackgroundTransparency = 0.9
            TglFrame.Parent = TabPage
            AddCorner(TglFrame, 10)

            local TglLabel = Instance.new("TextLabel")
            TglLabel.Size = UDim2.new(1, -60, 1, 0)
            TglLabel.Position = UDim2.new(0, 10, 0, 0)
            TglLabel.Text = Text
            TglLabel.TextColor3 = Settings.Colors.Text
            TglLabel.BackgroundTransparency = 1
            TglLabel.TextXAlignment = Enum.TextXAlignment.Left
            TglLabel.Parent = TglFrame

            local TglBtn = Instance.new("TextButton")
            TglBtn.Size = UDim2.new(0, 40, 0, 20)
            TglBtn.Position = UDim2.new(1, -50, 0.5, -10)
            TglBtn.BackgroundColor3 = Default and Settings.Colors.Accent or Color3.fromRGB(100, 100, 100)
            TglBtn.Text = ""
            TglBtn.Parent = TglFrame
            AddCorner(TglBtn, 10)

            local state = Default
            TglBtn.MouseButton1Click:Connect(function()
                state = not state
                Tween(TglBtn, {BackgroundColor3 = state and Settings.Colors.Accent or Color3.fromRGB(100, 100, 100)}, 0.2)
                Callback(state)
            end)
        end

        return TabInit
    end

    return WindowInit
end

return LiquidGlass
