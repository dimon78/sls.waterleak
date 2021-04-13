local master = tonumber(obj.get('master'), _)
local master_trigger = tonumber(obj.get('master_trigger'), _)
local service = tonumber(obj.get('service'), _)
local service_trigger = tonumber(obj.get('service_trigger'), _)

local relay = 0
local set = 0

local time = 10
local wl = {['wl_relay_1'] = {'wl_sensor_1', 'wl_sensor_2'}, ['wl_relay_2'] = {'sensor_3', 's4', 's5'}, ['wl_relay_3'] = {'s6'}}
local auto = false	

if master > 0 then
  	obj.set('service', os.time() + 60) 
  
	if master_trigger == 0 then 
    	master_trigger = os.time()
    	obj.set('master_trigger', master_trigger)

    	print('MASTER ON')    
    	set = -1
    end  
else
  	if service < os.time() then
    	if service_trigger == 0 then
      		service_trigger = os.time()
      		obj.set('service_trigger', service_trigger)
   			obj.set('service', os.time() + 60)   
      
      		print('SERVICE ON')
			set = -1
	   	end
    else    	
		if master_trigger > 0 then    
      		master_trigger = 0
    		obj.set('master_trigger', master_trigger)
 
        	print('MASTER OFF')      
      		set = 1
      	end
    end
end

local waiting = 0

for r,s in pairs(wl) do
  	relay = relay + 1
  	
  	local leak = 0  	
  	for i,n in pairs(s) do
    	local state = obj.get(n)
		if state == 'true' then
      		print('WL LEAK '.. r ..' ['.. n ..']')
      		if obj.get(r ..'_leak') ~= 'true' then
        		obj.set(r ..'_leak', 'true')
        		obj.set(r, -1)
        	end
      		leak = leak + 1
      	end
    end
  
  	if master == 0 then
 		if leak == 0 and (set == 1 or auto) then
      		if obj.get(r ..'_leak') == 'true' then
        		obj.set(r ..'_leak', 'false')
        		obj.set(r, 1)
        	end
      	end
    end
    
  	if leak == 0 and set ~= 0 then
    	if obj.get(r ..'_leak') ~= 'true' or master > 0 then
      		obj.set(r, set)
      	end
    end

	stage = tonumber(obj.get(r), _)
  	if stage == nil then
    	print('WL INIT '.. r)
    	stage = 0
    	
    	zigbee.set(r, "interlock", "TRUE")
    	zigbee.set(r, "state_l1", "OFF")
      	zigbee.set(r, "state_l2", "OFF")
  	elseif stage == 0 then
    	print('WL WAIT '.. r)
    	waiting = waiting + 1
    elseif stage < 0 then
    	print('WL CLOSE '.. r ..' ['.. tostring(stage) ..']')
    
    	if stage > -time then
      		if stage == -1 then
		    	zigbee.set(r, "state_l1", "ON")
      			zigbee.set(r, "state_l2", "OFF")            	
      		end

      		stage = stage - 1
      	else
	    	if master == 0 and service_trigger > 0 then
    			stage = 1
        	else
        		stage = 0
      		end
      		
      		zigbee.set(r, "state_l1", "OFF")
      		zigbee.set(r, "state_l2", "OFF")            	

			obj.set(r ..'_open', 'false')
    	end
    elseif stage > 0 then
    	print('WL OPEN '.. r ..' ['.. tostring(stage) ..']')
    
    	if stage < time then
      		if stage == 1 then
		    	zigbee.set(r, "state_l1", "OFF")
      			zigbee.set(r, "state_l2", "ON")            	
        	end

      		stage = stage + 1
      	else
        	stage = 0

      		zigbee.set(r, "state_l1", "OFF")
      		zigbee.set(r, "state_l2", "OFF")            	

			obj.set(r ..'_open', 'true')
    	end 
    end
  	obj.set(r, stage)
end  

if master == 0 and service_trigger > 0 and waiting == relay then
	obj.set('service_trigger', 0)
	
  	print('SERVICE OFF')
end  
