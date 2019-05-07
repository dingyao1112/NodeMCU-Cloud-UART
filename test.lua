print('hello')
conmunication_test_msg='\090\000\165'
ID_bind='\090\001\000\000\000'--ID:000000
ansbit='\090\128\000'
senddata=''
a=0

sk = net.createConnection(net.TCP, 0)
sk:connect(8080, "119.29.220.56")
print(sk:getpeer())
sk:on("receive", function(sk, c)
    if string.sub(c,2,2)=='\0' then
        uart.write(0, string.sub(c,4,-1))
    end
end)

sk:send(ID_bind)
uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 1)
uart.alt(1)

uart.on("data", 0,function(data)
    senddata=senddata..data
    if a==0 then
        a=1
        atimer = tmr.create()
        atimer:alarm(50, tmr.ALARM_AUTO, function()
        --uart.write(0, senddata)
            sk:send('\090\002\001'..senddata)
            atimer:unregister()
            senddata=''
            a=0
        end)
    else
        atimer:interval(50)
    end
end, 0)
--'\090\002\001'..

--[[local wait_wifi_timer = tmr.create()
   wait_wifi_timer:alarm(1000, tmr.ALARM_AUTO, function()
   sk:send(conmunication_test_msg)
   end)]]--
