-- FPS Boost Mobile - Tidak bisa di-toggle off kecuali rejoin
-- Khusus untuk perangkat mobile (HP/Tablet)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

-- Deteksi apakah di mobile
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_TABLET = UserInputService.TouchEnabled and GuiService:GetScreenResolution().Y > 1000

-- Pengaturan permanen untuk mobile
local PERMANENT_SETTINGS = {
    GraphicsLevel = 1, -- Level terendah
    Shadows = false,
    Particles = false,
    HighDetail = false,
    DarkMode = true -- Default aktif mode gelap
}

-- Simpan pengaturan asli (untuk informasi saja)
local OriginalSettings = {
    QualityLevel = settings().Rendering.QualityLevel,
    Brightness = Lighting.Brightness,
    Shadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd
}

-- Fungsi untuk menerapkan pengaturan permanen
local function applyPermanentMobileSettings()
    print("📱 Menerapkan FPS Boost Mobile (Permanen)")
    
    -- 1. Atur kualitas rendering
    settings().Rendering.QualityLevel = PERMANENT_SETTINGS.GraphicsLevel
    settings().Rendering.EagerBulkExecution = true
    
    -- 2. Optimasi Lighting untuk mobile
    Lighting.GlobalShadows = false
    Lighting.ShadowSoftness = 0
    Lighting.FogEnd = 500 -- Jarak fog pendek
    
    if PERMANENT_SETTINGS.DarkMode then
        -- Mode Gelap untuk battery saving
        Lighting.Brightness = 0.4
        Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 30)
        Lighting.Ambient = Color3.fromRGB(40, 40, 40)
        Lighting.FogColor = Color3.fromRGB(20, 20, 20)
        Lighting.ClockTime = 20 -- Malam hari
    else
        Lighting.Brightness = 1.2
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        Lighting.ClockTime = 14 -- Siang hari
    end
    
    -- 3. Nonaktifkan efek visual berat
    Lighting.Bloom.Enabled = false
    Lighting.Blur.Enabled = false
    Lighting.ColorCorrection.Enabled = false
    Lighting.SunRays.Enabled = false
    Lighting.Atmosphere.Density = 0.1 -- Sangat rendah
    
    -- 4. Optimasi workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Nonaktifkan semua partikel dan efek
        if not PERMANENT_SETTINGS.Particles then
            if obj:IsA("ParticleEmitter") or 
               obj:IsA("Trail") or 
               obj:IsA("Beam") or 
               obj:IsA("Smoke") or 
               obj:IsA("Fire") then
                obj.Enabled = false
            end
        end
        
        -- Sederhanakan material untuk semua object
        if obj:IsA("BasePart") then
            -- Skip jika bagian dari player atau tool penting
            local parentModel = obj:FindFirstAncestorWhichIsA("Model")
            local isPlayerPart = parentModel and (
                parentModel.Name == "Player" or 
                parentModel:FindFirstChild("Humanoid") or
                string.find(parentModel.Name:lower(), "player") or
                string.find(obj.Name:lower(), "head") or
                string.find(obj.Name:lower(), "torso") or
                string.find(obj.Name:lower(), "arm") or
                string.find(obj.Name:lower(), "leg")
            )
            
            if not isPlayerPart then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                
                -- Gunakan warna abu-abu untuk semua object non-player
                if PERMANENT_SETTINGS.DarkMode then
                    obj.BrickColor = BrickColor.new("Black")
                else
                    obj.BrickColor = BrickColor.new("Medium stone grey")
                end
            end
            
            -- Nonaktifkan decals/texture
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("Decal") or child:IsA("Texture") then
                    if not isPlayerPart then
                        child:Destroy() -- Hapus permanen
                    end
                end
            end
        end
        
        -- Sederhanakan meshes
        if obj:IsA("MeshPart") and not PERMANENT_SETTINGS.HighDetail then
            local parentModel = obj:FindFirstAncestorWhichIsA("Model")
            local isImportant = parentModel and (
                parentModel:FindFirstChild("Humanoid") or
                string.find(parentModel.Name:lower(), "weapon") or
                string.find(parentModel.Name:lower(), "tool")
            )
            
            if not isImportant then
                obj.TextureID = "" -- Hapus texture
            end
        end
    end
    
    -- 5. Optimasi Terrain
    if workspace:FindFirstChildOfClass("Terrain") then
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        terrain.Decoration = false
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0.8
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        
        if PERMANENT_SETTINGS.DarkMode then
            terrain.WaterColor = Color3.fromRGB(10, 10, 30)
        end
    end
    
    -- 6. Optimasi camera
    workspace.CurrentCamera.FieldOfView = 70 -- Default FOV
    
    -- 7. Frame rate cap untuk mobile
    if IS_MOBILE then
        RunService:SetThrottleFramerateEnabled(true)
        if IS_TABLET then
            settings().Rendering.FramerateManagerMode = 2 -- Medium untuk tablet
        else
            settings().Rendering.FramerateManagerMode = 1 -- Low untuk HP
        end
    end
    
    print("✅ FPS Boost diterapkan. Hanya akan reset setelah rejoin.")
end

-- Fungsi untuk membuat UI notifikasi mobile-friendly
local function createMobileNotification()
    local player = Players.LocalPlayer
    if not player or not player:FindFirstChild("PlayerGui") then return end
    
    -- Hapus notifikasi lama jika ada
    local oldScreen = player.PlayerGui:FindFirstChild("MobileFPSBoost")
    if oldScreen then oldScreen:Destroy() end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileFPSBoost"
    screenGui.DisplayOrder = 999
    screenGui.ResetOnSpawn = false -- PENTING: Tidak reset saat mati
    screenGui.IgnoreGuiInset = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = PERMANENT_SETTINGS.DarkMode and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(40, 40, 40)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel")
    title.Text = "📱 FPS BOOST MOBILE"
    title.Size = UDim2.new(1, -20, 0.5, 0)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(0, 255, 0)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "Mode Gelap Aktif • Graphics: Minimum • Reset setelah rejoin"
    subtitle.Size = UDim2.new(1, -20, 0.5, 0)
    subtitle.Position = UDim2.new(0, 10, 0.5, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    
    subtitle.Parent = frame
    title.Parent = frame
    frame.Parent = screenGui
    screenGui.Parent = player.PlayerGui
    
    -- Auto hide setelah 5 detik
    task.wait(5)
    
    local tween = game:GetService("TweenService"):Create(
        frame,
        TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, -70)}
    )
    tween:Play()
    
    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

-- Fungsi untuk menampilkan warning di output
local function showWarning()
    print("========================================")
    print("⚠️  PERINGATAN: FPS BOOST MOBILE")
    print("========================================")
    print("Pengaturan ini PERMANEN dan TIDAK BISA")
    print("dikembalikan selama sesi game berjalan!")
    print("")
    print("Fitur yang dinonaktifkan:")
    print("• Shadows & Lighting kompleks")
    print("• Particle effects")
    print("• High-detail textures")
    print("• Decals & post-processing")
    print("")
    print("🔄 Hanya akan reset setelah: REJOIN GAME")
    print("========================================")
end

-- Main execution
if IS_MOBILE then
    -- Tunggu player load
    local player = Players.LocalPlayer
    if player then
        -- Terapkan pengaturan
        applyPermanentMobileSettings()
        showWarning()
        
        -- Tampilkan notifikasi
        task.wait(1)
        createMobileNotification()
        
        -- Pastikan tetap aktif meskipun character mati/respawn
        player.CharacterAdded:Connect(function()
            task.wait(0.5) -- Tunggu character fully load
            applyPermanentMobileSettings()
        end)
    else
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        task.wait(2)
        applyPermanentMobileSettings()
        showWarning()
        task.wait(1)
        createMobileNotification()
    end
    
    -- Terapkan juga pada workspace changes
    workspace.DescendantAdded:Connect(function(descendant)
        task.wait() -- Yield untuk prevent infinite loop
        if PERMANENT_SETTINGS.DarkMode and descendant:IsA("BasePart") then
            -- Terapkan dark mode pada part baru
            local parentModel = descendant:FindFirstAncestorWhichIsA("Model")
            local isPlayerPart = parentModel and parentModel:FindFirstChild("Humanoid")
            
            if not isPlayerPart then
                descendant.BrickColor = BrickColor.new("Black")
                descendant.Material = Enum.Material.Plastic
            end
        end
    end)
else
    print("❌ Script ini khusus untuk perangkat mobile (HP/Tablet)")
    print("   Device terdeteksi: Desktop")
end

-- Optional: Simple toggle untuk testing (jika ada keyboard)
if not IS_MOBILE then
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            applyPermanentMobileSettings()
            print("FPS Boost diterapkan (forced)")
        end
    end)
end
