State_led_pin=0 --GPIO16--------------------------------

local timer1_control=1
local timer2_control=1
local timer3_control=1

local wait_uart_recieve_timer_control=nil
local whether_delete_uart_data=1
local uart_recieve_data=""
local ssid={}, rssi, authmode, channel
local wifi_ssid,wifi_password
local sum=0

function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
    print("Please find the WIFI you want to connect from the list of WIFI below and enter it number")
    print("\nNo.\t\t\tSSID\t\t\t\t\tBSSID\t\t\t  RSSI\t\tAUTHMODE\t\tCHANNEL")

    for bssid,v in pairs(t) do
        sum=sum+1
        ssid[sum], rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        print(sum,string.format("%32s",ssid[sum]).."\t"..bssid.."\t  "..rssi.."\t\t"..authmode.."\t\t\t"..channel)
        timer1_control=nil
    end
end

uart.on("data", 0,function(data)
    if whether_delete_uart_data==nil then
        uart_recieve_data=uart_recieve_data..data
        if wait_uart_recieve_timer_control==nil then
            wait_uart_recieve_timer_control=1
            wait_uart_recieve_timer = tmr.create()
            wait_uart_recieve_timer:alarm(50, tmr.ALARM_AUTO, function()
                wait_uart_recieve_timer:unregister()
                whether_delete_uart_data=1
                wait_uart_recieve_timer_control=nil
            end)
        else
            wait_uart_recieve_timer:interval(50)
        end
    end
end, 0)

--main

gpio.mode(State_led_pin, gpio.OUTPUT)-----------------------
print('Now configure the WIFI connection, the LED on the module will flash slowly during the configuration and connection process.')
print('If you enter the wrong information in the configuration, you need to restart the module.')
gpio.write(State_led_pin, gpio.LOW)
wifi.sta.getap(1, listap)
local timer1 = tmr.create()
timer1:alarm(100, tmr.ALARM_AUTO, function()
    if timer1_control == nil then
        timer1:unregister()
        print("Please enter the number of your choice")
        whether_delete_uart_data=nil
        timer2_control=nil
    end
end)
local timer2 = tmr.create()
timer2:alarm(100, tmr.ALARM_AUTO, function()
    if timer2_control == nil and whether_delete_uart_data==1 then
        uart_recieve_data=tonumber(uart_recieve_data)
        if uart_recieve_data and uart_recieve_data>0 and uart_recieve_data<sum+1 then
            timer2:unregister()
            wifi_ssid=ssid[uart_recieve_data]
            uart_recieve_data=''
            print("You have chosen "..wifi_ssid)
            print('Please enter the WIFI password')
            whether_delete_uart_data=nil
            timer3_control=nil
        else
            uart_recieve_data=''
            whether_delete_uart_data=nil
            print("Your choice is not in the list, please choose again")
        end
    end
end)
local timer3 = tmr.create()
timer3:alarm(100, tmr.ALARM_AUTO, function()
    if timer3_control == nil and whether_delete_uart_data==1 then
        timer3:unregister()
        if string.sub(uart_recieve_data,-1,-1)=='\n' then
            uart_recieve_data=string.sub(uart_recieve_data,1,-2)
        end
        wifi_password=uart_recieve_data
        print('The password you entered is:'..wifi_password)
        station_cfg = {}
        station_cfg.ssid = wifi_ssid
        station_cfg.pwd = wifi_password
        station_cfg.save = true
        wifi.sta.config(station_cfg)
        uart.write(0, "Connecting")
        local wait_wifi_connect_timer = tmr.create()
        wait_wifi_connect_timer:alarm(500, tmr.ALARM_AUTO, function()
            if wifi.sta.getip() == nil then
                uart.write(0, '.')
            else
                wait_wifi_connect_timer:unregister()
                print("\nConnected, IP is "..wifi.sta.getip())
                File_connect_wifi_executing=nil
                uart.on("data")--------------
                --dofile("test.lua")
            end
        end)
    end
end)

--main end

local state_led_control_timer = tmr.create()
state_led_control_timer:alarm(500, tmr.ALARM_AUTO, function()
    if gpio.read(State_led_pin) == 0 then
        gpio.write(State_led_pin, gpio.HIGH)
    else
        gpio.write(State_led_pin, gpio.LOW)
    end
end)

--[[
local timer = tmr.create()
timer:alarm(1000, tmr.ALARM_AUTO, function()
    if timer_control == nil then
        timer:unregister()
    end
end)
]]