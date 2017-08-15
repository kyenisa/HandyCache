--[[ <HCExtension>
@name			Delay limit by file type
@author			truefriend-cz
@version		1
@event			Init/delay_init
@event          BeforeViewInMonitor/delay_one
</HCExtension> ]]

function delay_init()
--	hc.put_msg(1, 'Delay OK init')
--hc.put_msg(1, 'Test OK')
end

function delay_one()
	accept = hc.get_global('accept')
	for_saving = hc.get_global('for_saving')
	for_loading_from_cache = hc.get_global('for_loading_from_cache')
	
	type_define = hc.get_global('type_define')
	afs_var = hc.get_global('afs_var')

	hc.call_me_for('AnswerHeaderReceived', 'delay_answer')
end

function delay_answer()
	delay_var = 'no'
	if check_allowed() or check_yes(afs_var) then
		if re.match(type_define, [[(Image)]], 1) then
			delay_var = 'yes'
			hc.set_global('delay_var', delay_var)
			sleep_interval=0.5 -- limit as sec.
			sleep_interval_num=sleep_interval*1000
			hc.sleep(sleep_interval_num)
			table.insert(monitor_string_array, 600, 'Delay limit: '..sleep_interval..' sec.')
		end
	end
end
