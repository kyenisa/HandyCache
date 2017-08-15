--[[ <HCExtension>
@name               Monitor hide
@author             truefriend-cz
@version            1
@description        Monitor Hide
@rule				https|http
@event 				BeforeViewInMonitor/Hide
</HCExtension> ]]

function Hide()
	if re.match(hc.url, [[.*(:443|:1001|:5228|chat|/search|min.js|BlueBox|app.standsapp.org|newtab|blogID|chrome-sync/command|api/stats/qoe|gen_204|osname).*]]) then
		hc.hide_in_active_list = true
		hc.hide_in_monitor = true
	end	
end
