

wifi.setmode(wifi.STATION)
station_cfg = {}
station_cfg.ssid = "F311 Wifi"
station_cfg.pwd = "f311wifi"
station_cfg.save = true
wifi.sta.config(station_cfg)

local wait_wifi_timer = tmr.create()
   wait_wifi_timer:alarm(1000, tmr.ALARM_AUTO, function()
        if wifi.sta.getip() == nil then
            print("Connecting...")
        else
            wait_wifi_timer:unregister()
            print("Connected, IP is "..wifi.sta.getip())
            dofile("test.lua")
        end
    end)