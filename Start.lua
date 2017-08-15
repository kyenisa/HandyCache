--[[ <HCExtension>
@name			Start
@author			truefriend-cz
@version		1
@event    		Init/init
</HCExtension> ]]

function init()
	hc.execute_cmd('SSLhandling off')
--	hc.put_msg(1, 'HandyCache started')


--	if hc.offline_on then
--		--hc.execute_cmd('LoadURL') Не срабатывает
--		hc.execute_cmd('OffLine off')
--	end	


--hc.sleep(500)
--	if not hc.ssl_handling_enabled() == true then
--		hc.execute_cmd('SSLhandling off')
--		hc.put_msg(1, 'SSL activated')
--	end


end
