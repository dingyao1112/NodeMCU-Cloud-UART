local ssid={}, rssi, authmode, channel
local wifi_ssid,wifi_password
local sum=0

local timer1 = tmr.create()
local timer2 = tmr.create()
local timer3 = tmr.create()
local timer4 = tmr.create()

function listap(t) -- (SSID : Authmode, RSSI, BSSID, Channel)
    print("Please find the WIFI you want to connect from the list of WIFI below and enter it number")
    print("\nNo.\t\t\tSSID\t\t\t\t\tBSSID\t\t\t  RSSI\t\tAUTHMODE\t\tCHANNEL")
    for bssid,v in pairs(t) do
        sum=sum+1
        ssid[sum], rssi, authmode, channel = string.match(v, "([^,]+),([^,]+),([^,]+),([^,]*)")
        print(sum,string.format("%32s",ssid[sum]).."\t"..bssid.."\t  "..rssi.."\t\t"..authmode.."\t\t\t"..channel)
        timer1:start()
    end
end

--main

print('Now configure the WIFI connection, the LED on the module will flash slowly during the configuration and connection process.')
print('If you enter the wrong information in the configuration, you need to restart the module.')
gpio.write(State_led_pin, gpio.LOW)
State_led_control_timer:interval(500)
State_led_control_timer:start()
wifi.sta.getap(1, listap)
timer1:register(1, tmr.ALARM_SINGLE, function()
    timer1:unregister()
    print("Please enter the number of your choice")
    Whether_delete_uart_data=nil
    timer2:start()
end)
timer2:register(100, tmr.ALARM_AUTO, function()
    if Whether_delete_uart_data==1 then
        Uart_recieve_data=tonumber(Uart_recieve_data)
        if Uart_recieve_data and Uart_recieve_data>0 and Uart_recieve_data<sum+1 then
            timer2:unregister()
            wifi_ssid=ssid[Uart_recieve_data]
            Uart_recieve_data=''
            print("You have chosen "..wifi_ssid)
            print('Please enter the WIFI password')
            Whether_delete_uart_data=nil
            timer3:start()
        else
            Uart_recieve_data=''
            Whether_delete_uart_data=nil
            print("Your choice is not in the list, please choose again")
        end
    end
end)
timer3:register(100, tmr.ALARM_AUTO, function()
    if Whether_delete_uart_data==1 then
        timer3:unregister()
        if string.sub(Uart_recieve_data,-1,-1)=='\n' then
            Uart_recieve_data=string.sub(Uart_recieve_data,1,-2)
        end
        wifi_password=Uart_recieve_data
        print('The password you entered is:'..wifi_password)
        station_cfg = {}
        station_cfg.ssid = wifi_ssid
        station_cfg.pwd = wifi_password
        station_cfg.save = true
        wifi.sta.config(station_cfg)
        uart.write(0, "Connecting")
        
        timer4:start()
    end
end)

timer4:register(500, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() == nil then
        uart.write(0, '.')
    else
        timer4:unregister()
        print("\nConnected, IP is "..wifi.sta.getip())
        Server_connect:dns("www.baidu.com", function(conn, ip)
            if ip then
                uart.on("data")--------------
                State_led_control_timer:stop()
                gpio.write(State_led_pin, gpio.HIGH)
                File_connect_wifi_executing=nil
            else
                print('This WIFI cannot connect to the Internet. Please select another WIFI to connect after rebooting.')
                tmr.delay(3000000)
                node.restart()
            end
        end)
    end
end)

--main end

--[[
local timer = tmr.create()
timer:register(1, tmr.ALARM_SINGLE, function()

end)

local timer = tmr.create()
timer:register(100, tmr.ALARM_AUTO, function()
    if then
        timer:unregister()
    end
end)

local timer = tmr.create()
timer:alarm(100, tmr.ALARM_AUTO, function()
    if then
        timer:unregister()
    end
end)
]]