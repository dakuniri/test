--[[
    ██╗     ██╗ ██████╗ ██╗   ██╗██╗██████╗      ██████╗ ██╗      █████╗ ███████╗███████╗
    ██║     ██║██╔═══██╗██║   ██║██║██╔══██╗    ██╔════╝ ██║     ██╔══██╗██╔════╝██╔════╝
    ██║     ██║██║   ██║██║   ██║██║██║  ██║    ██║  ███╗██║     ███████║███████╗███████╗
    ██║     ██║██║▄▄ ██║██║   ██║██║██║  ██║    ██║   ██║██║     ██╔══██║╚════██║╚════██║
    ███████╗██║╚██████╔╝╚██████╔╝██║██████╔╝    ╚██████╔╝███████╗██║  ██║███████║███████║
    ╚══════╝╚═╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚═════╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝
    
    Liquid Glass UI Library - v2.0.0
    透明感とリキッドアニメーションを持つ次世代UIライブラリ
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

-- テーマ設定
local Themes = {
    Default = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(150, 200, 255),
        Accent = Color3.fromRGB(100, 180, 255),
        Background = Color3.fromRGB(20, 20, 30),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200)
    },
    Dark = {
        Primary = Color3.fromRGB(200, 200, 200),
        Secondary = Color3.fromRGB(100, 100, 120),
        Accent = Color3.fromRGB(80, 80, 100),
        Background = Color3.fromRGB(10, 10, 15),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180)
    },
    Light = {
        Primary = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(200, 220, 255),
        Accent = Color3.fromRGB(100, 150, 255),
        Background = Color3.fromRGB(250, 250, 255),
        Text = Color3.fromRGB(30, 30, 30),
        SubText = Color3.fromRGB(80, 80, 80)
    },
    Ocean = {
        Primary = Color3.fromRGB(200, 240, 255),
        Secondary = Color3.fromRGB(100, 200, 240),
        Accent = Color3.fromRGB(50, 150, 255),
        Background = Color3.fromRGB(15, 25, 35),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 220, 240)
    },
    Sunset = {
        Primary = Color3.fromRGB(255, 200, 150),
        Secondary = Color3.fromRGB(255, 150, 100),
        Accent = Color3.fromRGB(255, 100, 80),
        Background = Color3.fromRGB(30, 20, 25),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(255, 200, 180)
    },
    Forest = {
        Primary = Color3.fromRGB(180, 255, 180),
        Secondary = Color3.fromRGB(120, 200, 120),
        Accent = Color3.fromRGB(80, 180, 80),
        Background = Color3.fromRGB(15, 25, 15),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 255, 200)
    },
    Purple = {
        Primary = Color3.fromRGB(220, 180, 255),
        Secondary = Color3.fromRGB(180, 120, 255),
        Accent = Color3.fromRGB(150, 80, 255),
        Background = Color3.fromRGB(20, 15, 30),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(220, 200, 255)
    }
}

-- 現在の設定
local Settings = {
    Colors = Themes.Default,
    Animation = {
        Speed = 0.3,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },
    Glass = {
        Transparency = 0.15,
        BlurSize = 20,
        BorderThickness = 1.5
    },
    CurrentTheme = "Default"
}

-- グローバル参照保存
local GlobalElements = {
    MainFrame = nil,
    ScreenGui = nil,
    NotificationContainer = nil,
    ThemeObjects = {}
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
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Ripple
    
    Tween(Ripple, {
        Size = UDim2.new(0, 300, 0, 300),
        BackgroundTransparency = 1
    }, 0.6).Completed:Connect(function()
        Ripple:Destroy()
    end)
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
    
    -- テーマ変更用に保存
    table.insert(GlobalElements.ThemeObjects, {Object = Gradient, Type = "Gradient"})
    
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
        local rotation = 45 + math.sin(elapsed * 0.8) * 20
        Gradient.Rotation = rotation
        
        local wave = (math.sin(elapsed * 1.2) + 1) / 2
        Gradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.75 + wave * 0.1),
            NumberSequenceKeypoint.new(0.5, 0.85 + wave * 0.15),
            NumberSequenceKeypoint.new(1, 0.75 + wave * 0.1)
        }
    end)
    
    return connection
end

-- テーマ変更関数
function LiquidGlass:SetTheme(ThemeName)
    if not Themes[ThemeName] then
        warn("Theme '" .. ThemeName .. "' not found!")
        return
    end
    
    Settings.Colors = Themes[ThemeName]
    Settings.CurrentTheme = ThemeName
    
    -- すべてのテーマオブジェクトを更新
    for _, item in ipairs(GlobalElements.ThemeObjects) do
        if item.Object and item.Object.Parent then
            if item.Type == "Gradient" then
                item.Object.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Settings.Colors.Primary),
                    ColorSequenceKeypoint.new(0.5, Settings.Colors.Secondary),
                    ColorSequenceKeypoint.new(1, Settings.Colors.Accent)
                }
            elseif item.Type == "Background" then
                Tween(item.Object, {BackgroundColor3 = Settings.Colors.Background}, 0.5)
            elseif item.Type == "Text" then
                Tween(item.Object, {TextColor3 = Settings.Colors.Text}, 0.5)
            elseif item.Type == "SubText" then
                Tween(item.Object, {TextColor3 = Settings.Colors.SubText}, 0.5)
            elseif item.Type == "Accent" then
                Tween(item.Object, {BackgroundColor3 = Settings.Colors.Accent}, 0.5)
            elseif item.Type == "Primary" then
                Tween(item.Object, {BackgroundColor3 = Settings.Colors.Primary}, 0.5)
            elseif item.Type == "Stroke" then
                Tween(item.Object, {Color = Settings.Colors.Primary}, 0.5)
            end
        end
    end
end

-- 通知システム
function LiquidGlass:Notify(Config)
    Config = Config or {}
    Config.Title = Config.Title or "通知"
    Config.Content = Config.Content or "通知内容"
    Config.Duration = Config.Duration or 3
    Config.Icon = Config.Icon or "🔔"
    
    if not GlobalElements.NotificationContainer then
        return
    end
    
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(1, -20, 0, 0)
    Notification.BackgroundColor3 = Settings.Colors.Background
    Notification.BackgroundTransparency = 0.1
    Notification.BorderSizePixel = 0
    Notification.ClipsDescendants = true
    Notification.Parent = GlobalElements.NotificationContainer
    
    AddCorner(Notification, 12)
    AddStroke(Notification, Settings.Colors.Primary, 1, 0.5)
    
    table.insert(GlobalElements.ThemeObjects, {Object = Notification, Type = "Background"})
    
    local NotifGradient = AddGradient(Notification)
    StartLiquidAnimation(NotifGradient)
    
    local IconLabel = Instance.new("TextLabel")
    IconLabel.Size = UDim2.new(0, 40, 1, 0)
    IconLabel.Position = UDim2.new(0, 10, 0, 0)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = Config.Icon
    IconLabel.TextColor3 = Settings.Colors.Text
    IconLabel.TextSize = 24
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.Parent = Notification
    
    table.insert(GlobalElements.ThemeObjects, {Object = IconLabel, Type = "Text"})
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -60, 1, 0)
    ContentFrame.Position = UDim2.new(0, 50, 0, 0)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Notification
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 20)
    TitleLabel.Position = UDim2.new(0, 0, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Config.Title
    TitleLabel.TextColor3 = Settings.Colors.Text
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = ContentFrame
    
    table.insert(GlobalElements.ThemeObjects, {Object = TitleLabel, Type = "Text"})
    
    local ContentLabel = Instance.new("TextLabel")
    ContentLabel.Size = UDim2.new(1, 0, 0, 18)
    ContentLabel.Position = UDim2.new(0, 0, 0, 28)
    ContentLabel.BackgroundTransparency = 1
    ContentLabel.Text = Config.Content
    ContentLabel.TextColor3 = Settings.Colors.SubText
    ContentLabel.TextSize = 12
    ContentLabel.Font = Enum.Font.Gotham
    ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContentLabel.TextWrapped = true
    ContentLabel.Parent = ContentFrame
    
    table.insert(GlobalElements.ThemeObjects, {Object = ContentLabel, Type = "SubText"})
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 3)
    ProgressBar.Position = UDim2.new(0, 0, 1, -3)
    ProgressBar.BackgroundColor3 = Settings.Colors.Accent
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = Notification
    
    table.insert(GlobalElements.ThemeObjects, {Object = ProgressBar, Type = "Accent"})
    
    -- アニメーション
    Notification.Size = UDim2.new(1, -20, 0, 0)
    Tween(Notification, {Size = UDim2.new(1, -20, 0, 70)}, 0.3)
    
    -- プログレスバー
    spawn(function()
        wait(0.3)
        Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, Config.Duration)
    end)
    
    -- 自動削除
    spawn(function()
        wait(Config.Duration + 0.3)
        Tween(Notification, {Size = UDim2.new(1, -20, 0, 0)}, 0.3).Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
end

-- メイン関数
function LiquidGlass:CreateWindow(Config)
    local WindowInit = {}
    
    Config = Config or {}
    Config.Name = Config.Name or "Liquid Glass UI"
    Config.LoadingTitle = Config.LoadingTitle or "Liquid Glass"
    Config.LoadingSubtitle = Config.LoadingSubtitle or "Loading..."
    
    -- ScreenGui作成
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LiquidGlass_" .. math.random(1000, 9999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    GlobalElements.ScreenGui = ScreenGui
    
    -- CoreGuiに保護して配置
    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    
    if not success then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    -- 通知コンテナ
    local NotificationContainer = Instance.new("Frame")
    NotificationContainer.Name = "NotificationContainer"
    NotificationContainer.Size = UDim2.new(0, 350, 0, 500)
    NotificationContainer.Position = UDim2.new(1, -370, 0, 20)
    NotificationContainer.BackgroundTransparency = 1
    NotificationContainer.Parent = ScreenGui
    
    GlobalElements.NotificationContainer = NotificationContainer
    
    local NotifList = Instance.new("UIListLayout")
    NotifList.Padding = UDim.new(0, 10)
    NotifList.SortOrder = Enum.SortOrder.LayoutOrder
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifList.Parent = NotificationContainer
    
    -- ローディング画面
    local LoadingScreen = Instance.new("Frame")
    LoadingScreen.Name = "LoadingScreen"
    LoadingScreen.Size = UDim2.new(1, 0, 1, 0)
    LoadingScreen.BackgroundColor3 = Settings.Colors.Background
    LoadingScreen.BackgroundTransparency = 0
    LoadingScreen.BorderSizePixel = 0
    LoadingScreen.Parent = ScreenGui
    
    local LoadingGradient = AddGradient(LoadingScreen)
    StartLiquidAnimation(LoadingGradient)
    
    local LoadingTitle = Instance.new("TextLabel")
    LoadingTitle.Size = UDim2.new(0, 400, 0, 60)
    LoadingTitle.Position = UDim2.new(0.5, -200, 0.5, -80)
    LoadingTitle.BackgroundTransparency = 1
    LoadingTitle.Text = Config.LoadingTitle
    LoadingTitle.TextColor3 = Settings.Colors.Text
    LoadingTitle.TextSize = 42
    LoadingTitle.Font = Enum.Font.GothamBold
    LoadingTitle.Parent = LoadingScreen
    
    local LoadingSubtitle = Instance.new("TextLabel")
    LoadingSubtitle.Size = UDim2.new(0, 400, 0, 30)
    LoadingSubtitle.Position = UDim2.new(0.5, -200, 0.5, -10)
    LoadingSubtitle.BackgroundTransparency = 1
    LoadingSubtitle.Text = Config.LoadingSubtitle
    LoadingSubtitle.TextColor3 = Settings.Colors.SubText
    LoadingSubtitle.TextSize = 16
    LoadingSubtitle.Font = Enum.Font.Gotham
    LoadingSubtitle.Parent = LoadingScreen
    
    local LoadingBar = Instance.new("Frame")
    LoadingBar.Size = UDim2.new(0, 400, 0, 4)
    LoadingBar.Position = UDim2.new(0.5, -200, 0.5, 40)
    LoadingBar.BackgroundColor3 = Settings.Colors.Primary
    LoadingBar.BackgroundTransparency = 0.8
    LoadingBar.BorderSizePixel = 0
    LoadingBar.Parent = LoadingScreen
    AddCorner(LoadingBar, 2)
    
    local LoadingFill = Instance.new("Frame")
    LoadingFill.Size = UDim2.new(0, 0, 1, 0)
    LoadingFill.BackgroundColor3 = Settings.Colors.Accent
    LoadingFill.BorderSizePixel = 0
    LoadingFill.Parent = LoadingBar
    AddCorner(LoadingFill, 2)
    
    -- ローディングアニメーション
    Tween(LoadingFill, {Size = UDim2.new(1, 0, 1, 0)}, 1.5).Completed:Connect(function()
        wait(0.3)
        Tween(LoadingScreen, {BackgroundTransparency = 1}, 0.5)
        Tween(LoadingTitle, {TextTransparency = 1}, 0.5)
        Tween(LoadingSubtitle, {TextTransparency = 1}, 0.5)
        Tween(LoadingBar, {BackgroundTransparency = 1}, 0.5)
        Tween(LoadingFill, {BackgroundTransparency = 1}, 0.5).Completed:Connect(function()
            LoadingScreen:Destroy()
        end)
    end)
    
    wait(1.8)
    
    -- メインウィンドウ
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 650)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -325)
    MainFrame.BackgroundColor3 = Settings.Colors.Background
    MainFrame.BackgroundTransparency = Settings.Glass.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui
    
    GlobalElements.MainFrame = MainFrame
    table.insert(GlobalElements.ThemeObjects, {Object = MainFrame, Type = "Background"})
    
    AddCorner(MainFrame, 16)
    local MainStroke = AddStroke(MainFrame)
    local MainGradient = AddGradient(MainFrame)
    StartLiquidAnimation(MainGradient)
    
    -- グローエフェクト
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(1, 40, 1, 40)
    Glow.Position = UDim2.new(0, -20, 0, -20)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Settings.Colors.Accent
    Glow.ImageTransparency = 0.7
    Glow.ZIndex = 0
    Glow.Parent = MainFrame
    
    table.insert(GlobalElements.ThemeObjects, {Object = Glow, Type = "Accent", Property = "ImageColor3"})
    
    -- タイトルバー
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Config.Name
    TitleLabel.TextColor3 = Settings.Colors.Text
    TitleLabel.TextSize = 20
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    table.insert(GlobalElements.ThemeObjects, {Object = TitleLabel, Type = "Text"})
    
    -- 閉じるボタン
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 40, 0, 40)
    CloseButton.Position = UDim2.new(1, -50, 0, 5)
    CloseButton.BackgroundColor3 = Settings.Colors.Primary
    CloseButton.BackgroundTransparency = 0.9
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Settings.Colors.Text
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    AddCorner(CloseButton, 10)
    
    table.insert(GlobalElements.ThemeObjects, {Object = CloseButton, Type = "Primary"})
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundTransparency = 0.7, BackgroundColor3 = Color3.fromRGB(255, 80, 80)})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundTransparency = 0.9, BackgroundColor3 = Settings.Colors.Primary})
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        CreateRipple(CloseButton, Vector2.new(20, 20))
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.5).Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)
    
    -- タブコンテナ
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 130, 1, -60)
    TabContainer.Position = UDim2.new(0, 10, 0, 55)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 8)
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Parent = TabContainer
    
    -- コンテンツコンテナ
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -160, 1, -60)
    ContentContainer.Position = UDim2.new(0, 150, 0, 55)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame
    
    -- ドラッグ機能
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- タブ作成関数
    function WindowInit:CreateTab(Name, Icon)
        local TabInit = {}
        
        Icon = Icon or "📄"
        
        -- タブボタン
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Name
        TabButton.Size = UDim2.new(1, 0, 0, 40)
        TabButton.BackgroundColor3 = Settings.Colors.Primary
        TabButton.BackgroundTransparency = 0.9
        TabButton.BorderSizePixel = 0
        TabButton.Text = "  " .. Icon .. "  " .. Name
        TabButton.TextColor3 = Settings.Colors.SubText
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.ClipsDescendants = true
        TabButton.Parent = TabContainer
        
        AddCorner(TabButton, 10)
        
        table.insert(GlobalElements.ThemeObjects, {Object = TabButton, Type = "Primary"})
        
        -- タブコンテンツ
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = Name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Settings.Colors.Accent
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.Padding = UDim.new(0, 10)
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Parent = TabContent
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 10)
        end)
        
        -- タブボタンイベント
        TabButton.MouseEnter:Connect(function()
            if TabContent.Visible == false then
                Tween(TabButton, {BackgroundTransparency = 0.8})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabContent.Visible == false then
                Tween(TabButton, {BackgroundTransparency = 0.9})
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            CreateRipple(TabButton, Vector2.new(65, 20))
            
            -- すべてのタブを非表示
            for _, tab in pairs(ContentContainer:GetChildren()) do
                if tab:IsA("ScrollingFrame") then
                    tab.Visible = false
                end
            end
            
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, {BackgroundTransparency = 0.9, TextColor3 = Settings.Colors.SubText})
                end
            end
            
            -- 選択されたタブを表示
            TabContent.Visible = true
            Tween(TabButton, {BackgroundTransparency = 0.7, TextColor3 = Settings.Colors.Text})
        end)
        
        -- 最初のタブを自動選択
        if #TabContainer:GetChildren() == 2 then
            TabContent.Visible = true
            TabButton.BackgroundTransparency = 0.7
            TabButton.TextColor3 = Settings.Colors.Text
        end
        
        -- ボタン作成
        function TabInit:CreateButton(Name, Callback)
            local Button = Instance.new("TextButton")
            Button.Name = Name
            Button.Size = UDim2.new(1, -10, 0, 45)
            Button.BackgroundColor3 = Settings.Colors.Primary
            Button.BackgroundTransparency = 0.85
            Button.BorderSizePixel = 0
            Button.Text = Name
            Button.TextColor3 = Settings.Colors.Text
            Button.TextSize = 15
            Button.Font = Enum.Font.GothamMedium
            Button.ClipsDescendants = true
            Button.Parent = TabContent
            
            AddCorner(Button, 12)
            local ButtonStroke = AddStroke(Button, Settings.Colors.Primary, 1, 0.7)
            
            table.insert(GlobalElements.ThemeObjects, {Object = Button, Type = "Primary"})
            table.insert(GlobalElements.ThemeObjects, {Object = Button, Type = "Text", Property = "TextColor3"})
            
            Button.MouseEnter:Connect(function()
                Tween(Button, {BackgroundTransparency = 0.75, Size = UDim2.new(1, -10, 0, 48)})
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(Button, {BackgroundTransparency = 0.85, Size = UDim2.new(1, -10, 0, 45)})
            end)
            
            Button.MouseButton1Down:Connect(function()
                Tween(Button, {Size = UDim2.new(1, -10, 0, 42)}, 0.1)
            end)
            
            Button.MouseButton1Up:Connect(function()
                Tween(Button, {Size = UDim2.new(1, -10, 0, 45)}, 0.1)
            end)
            
            Button.MouseButton1Click:Connect(function()
                local mousePos = UserInputService:GetMouseLocation()
                local buttonPos = Button.AbsolutePosition
                local relativePos = Vector2.new(mousePos.X - buttonPos.X, mousePos.Y - buttonPos.Y - 36)
                CreateRipple(Button, relativePos)
                
                pcall(Callback)
            end)
            
            return Button
        end
        
        -- トグル作成
        function TabInit:CreateToggle(Name, Default, Callback)
            Default = Default or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = Name
            ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
            ToggleFrame.BackgroundColor3 = Settings.Colors.Primary
            ToggleFrame.BackgroundTransparency = 0.85
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            
            AddCorner(ToggleFrame, 12)
            AddStroke(ToggleFrame, Settings.Colors.Primary, 1, 0.7)
            
            table.insert(GlobalElements.ThemeObjects, {Object = ToggleFrame, Type = "Primary"})
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Settings.Colors.Text
            Label.TextSize = 15
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            table.insert(GlobalElements.ThemeObjects, {Object = Label, Type = "Text"})
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 50, 0, 26)
            ToggleButton.Position = UDim2.new(1, -60, 0.5, -13)
            ToggleButton.BackgroundColor3 = Default and Settings.Colors.Accent or Color3.fromRGB(80, 80, 80)
            ToggleButton.BackgroundTransparency = 0.3
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            
            AddCorner(ToggleButton, 13)
            
            if Default then
                table.insert(GlobalElements.ThemeObjects, {Object = ToggleButton, Type = "Accent"})
            end
            
            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 20, 0, 20)
            Indicator.Position = Default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            Indicator.BackgroundColor3 = Settings.Colors.Text
            Indicator.BorderSizePixel = 0
            Indicator.Parent = ToggleButton
            
            AddCorner(Indicator, 10)
            
            table.insert(GlobalElements.ThemeObjects, {Object = Indicator, Type = "Text", Property = "BackgroundColor3"})
            
            local Enabled = Default
            
            ToggleButton.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                
                Tween(ToggleButton, {
                    BackgroundColor3 = Enabled and Settings.Colors.Accent or Color3.fromRGB(80, 80, 80)
                })
                
                Tween(Indicator, {
                    Position = Enabled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
                }, 0.25)
                
                pcall(function()
                    Callback(Enabled)
                end)
            end)
            
            return ToggleFrame
        end
        
        -- スライダー作成
        function TabInit:CreateSlider(Name, Min, Max, Default, Callback)
            Min = Min or 0
            Max = Max or 100
            Default = Default or 50
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = Name
            SliderFrame.Size = UDim2.new(1, -10, 0, 55)
            SliderFrame.BackgroundColor3 = Settings.Colors.Primary
            SliderFrame.BackgroundTransparency = 0.85
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            
            AddCorner(SliderFrame, 12)
            AddStroke(SliderFrame, Settings.Colors.Primary, 1, 0.7)
            
            table.insert(GlobalElements.ThemeObjects, {Object = SliderFrame, Type = "Primary"})
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 0, 20)
            Label.Position = UDim2.new(0, 15, 0, 8)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Settings.Colors.Text
            Label.TextSize = 15
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame
            
            table.insert(GlobalElements.ThemeObjects, {Object = Label, Type = "Text"})
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(0.3, -15, 0, 20)
            ValueLabel.Position = UDim2.new(0.7, 0, 0, 8)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(Default)
            ValueLabel.TextColor3 = Settings.Colors.Accent
            ValueLabel.TextSize = 15
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame
            
            table.insert(GlobalElements.ThemeObjects, {Object = ValueLabel, Type = "Accent", Property = "TextColor3"})
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(1, -30, 0, 6)
            SliderBar.Position = UDim2.new(0, 15, 1, -18)
            SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SliderBar.BackgroundTransparency = 0.5
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame
            
            AddCorner(SliderBar, 3)
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            SliderFill.BackgroundColor3 = Settings.Colors.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            
            AddCorner(SliderFill, 3)
            
            table.insert(GlobalElements.ThemeObjects, {Object = SliderFill, Type = "Accent"})
            
            local SliderButton = Instance.new("TextButton")
            SliderButton.Size = UDim2.new(0, 18, 0, 18)
            SliderButton.Position = UDim2.new((Default - Min) / (Max - Min), -9, 0.5, -9)
            SliderButton.BackgroundColor3 = Settings.Colors.Text
            SliderButton.BorderSizePixel = 0
            SliderButton.Text = ""
            SliderButton.Parent = SliderBar
            
            AddCorner(SliderButton, 9)
            
            table.insert(GlobalElements.ThemeObjects, {Object = SliderButton, Type = "Text", Property = "BackgroundColor3"})
            
            local Dragging = false
            
            SliderButton.MouseButton1Down:Connect(function()
                Dragging = true
                Tween(SliderButton, {Size = UDim2.new(0, 22, 0, 22)}, 0.15)
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    Tween(SliderButton, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    local relative = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    local value = math.floor(Min + (Max - Min) * relative)
                    
                    SliderFill.Size = UDim2.new(relative, 0, 1, 0)
                    SliderButton.Position = UDim2.new(relative, -9, 0.5, -9)
                    ValueLabel.Text = tostring(value)
                    
                    pcall(function()
                        Callback(value)
                    end)
                end
            end)
            
            return SliderFrame
        end
        
        -- ドロップダウン作成
        function TabInit:CreateDropdown(Name, Options, Default, Callback)
            Options = Options or {}
            Default = Default or Options[1] or "None"
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = Name
            DropdownFrame.Size = UDim2.new(1, -10, 0, 45)
            DropdownFrame.BackgroundColor3 = Settings.Colors.Primary
            DropdownFrame.BackgroundTransparency = 0.85
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ClipsDescendants = false
            DropdownFrame.Parent = TabContent
            
            AddCorner(DropdownFrame, 12)
            AddStroke(DropdownFrame, Settings.Colors.Primary, 1, 0.7)
            
            table.insert(GlobalElements.ThemeObjects, {Object = DropdownFrame, Type = "Primary"})
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = Name
            Label.TextColor3 = Settings.Colors.Text
            Label.TextSize = 15
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropdownFrame
            
            table.insert(GlobalElements.ThemeObjects, {Object = Label, Type = "Text"})
            
            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0.5, -40, 1, 0)
            SelectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
            SelectedLabel.BackgroundTransparency = 1
            SelectedLabel.Text = Default
            SelectedLabel.TextColor3 = Settings.Colors.Accent
            SelectedLabel.TextSize = 14
            SelectedLabel.Font = Enum.Font.Gotham
            SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            SelectedLabel.Parent = DropdownFrame
            
            table.insert(GlobalElements.ThemeObjects, {Object = SelectedLabel, Type = "Accent", Property = "TextColor3"})
            
            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Settings.Colors.SubText
            Arrow.TextSize = 12
            Arrow.Font = Enum.Font.Gotham
            Arrow.Parent = DropdownFrame
            
            table.insert(GlobalElements.ThemeObjects, {Object = Arrow, Type = "SubText"})
            
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
            OptionsFrame.Position = UDim2.new(0, 0, 1, 5)
            OptionsFrame.BackgroundColor3 = Settings.Colors.Background
            OptionsFrame.BackgroundTransparency = 0.1
            OptionsFrame.BorderSizePixel = 0
            OptionsFrame.ClipsDescendants = true
            OptionsFrame.Visible = false
            OptionsFrame.ZIndex = 10
            OptionsFrame.Parent = DropdownFrame
            
            AddCorner(OptionsFrame, 12)
            AddStroke(OptionsFrame, Settings.Colors.Primary, 1, 0.5)
            
            table.insert(GlobalElements.ThemeObjects, {Object = OptionsFrame, Type = "Background"})
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Padding = UDim.new(0, 2)
            OptionsList.Parent = OptionsFrame
            
            local isOpen = false
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 1, 0)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.Parent = DropdownFrame
            
            DropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                
                if isOpen then
                    OptionsFrame.Visible = true
                    Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, math.min(#Options * 32 + 4, 150))})
                    Tween(Arrow, {Rotation = 180})
                else
                    Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)})
                    Tween(Arrow, {Rotation = 0})
                    wait(0.3)
                    OptionsFrame.Visible = false
                end
            end)
            
            for _, option in ipairs(Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, -4, 0, 30)
                OptionButton.BackgroundColor3 = Settings.Colors.Primary
                OptionButton.BackgroundTransparency = 0.9
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = option
                OptionButton.TextColor3 = Settings.Colors.Text
                OptionButton.TextSize = 14
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Parent = OptionsFrame
                
                AddCorner(OptionButton, 8)
                
                table.insert(GlobalElements.ThemeObjects, {Object = OptionButton, Type = "Primary"})
                table.insert(GlobalElements.ThemeObjects, {Object = OptionButton, Type = "Text", Property = "TextColor3"})
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundTransparency = 0.7})
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundTransparency = 0.9})
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    SelectedLabel.Text = option
                    isOpen = false
                    Tween(OptionsFrame, {Size = UDim2.new(1, 0, 0, 0)})
                    Tween(Arrow, {Rotation = 0})
                    wait(0.3)
                    OptionsFrame.Visible = false
                    
                    pcall(function()
                        Callback(option)
                    end)
                end)
            end
            
            return DropdownFrame
        end
        
        -- ラベル作成
        function TabInit:CreateLabel(Text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 35)
            Label.BackgroundTransparency = 1
            Label.Text = Text
            Label.TextColor3 = Settings.Colors.SubText
            Label.TextSize = 14
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.Parent = TabContent
            
            table.insert(GlobalElements.ThemeObjects, {Object = Label, Type = "SubText"})
            
            return Label
        end
        
        -- セクション作成
        function TabInit:CreateSection(Name)
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, -10, 0, 30)
            Section.BackgroundTransparency = 1
            Section.Parent = TabContent
            
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, 0, 1, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = "— " .. Name .. " —"
            SectionLabel.TextColor3 = Settings.Colors.Accent
            SectionLabel.TextSize = 16
            SectionLabel.Font = Enum.Font.GothamBold
            SectionLabel.Parent = Section
            
            table.insert(GlobalElements.ThemeObjects, {Object = SectionLabel, Type = "Accent", Property = "TextColor3"})
            
            return Section
        end
        
        return TabInit
    end
    
    -- ウィンドウにNotifyとSetTheme機能を追加
    WindowInit.Notify = function(Config)
        return LiquidGlass:Notify(Config)
    end
    
    WindowInit.SetTheme = function(ThemeName)
        return LiquidGlass:SetTheme(ThemeName)
    end
    
    return WindowInit
end

return LiquidGlass
