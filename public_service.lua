Whether_delete_uart_data=1
Uart_recieve_data=""

State_led_pin=0 --GPIO16--------------------------------
gpio.mode(State_led_pin, gpio.OUTPUT)-----------------------

local wait_uart_recieve_timer_control=nil

local wait_uart_recieve_timer = tmr.create()
wait_uart_recieve_timer:register(25, tmr.ALARM_AUTO, function()
    wait_uart_recieve_timer:stop()
    Whether_delete_uart_data=1
    wait_uart_recieve_timer_control=nil
end)

uart.on("data", 0,function(data)
    if Whether_delete_uart_data==nil then
        Uart_recieve_data=Uart_recieve_data..data
        if wait_uart_recieve_timer_control==nil then
            wait_uart_recieve_timer_control=1
            wait_uart_recieve_timer:start()
        else
            wait_uart_recieve_timer:interval(25)
        end
    end
end, 0)

State_led_control_timer = tmr.create()
State_led_control_timer:register(500, tmr.ALARM_AUTO, function()
    if gpio.read(State_led_pin) == 0 then
        gpio.write(State_led_pin, gpio.HIGH)
    else
        gpio.write(State_led_pin, gpio.LOW)
    end
end)


dofile("conncet_wifi.lua")---------------------
