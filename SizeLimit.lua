--[[ <HCExtension>
@name			Size limit
@author			truefriend-cz
@version		1
@event			Init/limit_init
@event			BeforeViewInMonitor/limit_one
</HCExtension> ]]

function limit_init()
--	hc.put_msg(1, 'Limit OK init')
--hc.put_msg(1, 'Test OK')
end

function limit_one()
	accept = hc.get_global('accept')
	for_saving = hc.get_global('for_saving')
	for_loading_from_cache = hc.get_global('for_loading_from_cache')
	
	type_define = hc.get_global('type_define')
	size_code_num = hc.get_global('size_code_num')

	hc.call_me_for('AnswerHeaderReceived', 'limit_answer')
end

function limit_answer()
	limit_var = 'no'
	if check_allowed() then
		if re.match(type_define, [[(Image|Style)]]) then
			_,_,x = string.find(hc.answer_header, '[cC]ontent%-[lL]ength: *(%d+)')
			size_code = tonumber(x)
			size_code_num = (size_code)/1000
			mult = 10^(2 or 0)
			size_code_num = math.floor(size_code_num * mult) / mult
			result_size_min = 0.20 -- min limit as kB
			result_size_max = 512 -- max limit as kB
			if size_code_num <= result_size_min or size_code_num >= result_size_max then
				hc.action = 'dont_save'
				limit_var = 'yes'
				for_saving = 'no'
				hc.set_global('limit_var', limit_var)
				hc.set_global('for_saving', for_saving)
				if size_code_num < result_size_min then
					table.insert(monitor_string_array, 5, 'No saved: min limit is '..result_size_min..' kB (file size:'..size_code_num..' kB)')
					table.insert(monitor_color_array, 5, rgb(153, 0, 0))
				else
					table.insert(monitor_string_array, 5, 'No saved: max limit is '..result_size_max..' kB (file size:'..size_code_num..' kB)')
					table.insert(monitor_color_array, 5, rgb(153, 0, 0))
				end
			end
		end
	end
end
