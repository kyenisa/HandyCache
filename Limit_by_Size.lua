--[[ <HCExtension>
@name			Limit by Size
@author			truefriend-cz
@version		1.1
@description	Script for Limit saving data by Size for specify type (must use with truefriend-cz script pack only) - Extension list position priority: 3
@license		CC BY-NC-SA (Attribution-NonCommercial-ShareAlike - https://creativecommons.org/licenses/by-nc-sa/)
@event			AnswerHeaderReceived
</HCExtension> ]]

function AnswerHeaderReceived()

	local size_min = 0.40 -- min limit as kB
	local size_max = 512 -- max limit as kB

	if for_saving == 'yes' then
		local function set_var(x, y)
			_G[x] = y
		end
		local function num_repack(n)
			if n > 1000000 then
				return string.format("%.2f GB", (n / 1000000))
			elseif n > 1000 then
				return string.format("%.2f MB", (n / 1000))
			else
				return string.format("%.2f kB", n)
			end
		end
		if re.match(file_type_group, [[(Image|Style)]]) then
			MY_EXTENSION_DATA = MY_EXTENSION_DATA or {}
			MY_EXTENSION_DATA[hc.monitor_index] = { monitor_string_array={} }
			local data = MY_EXTENSION_DATA[hc.monitor_index]
			local _,_,x = string.find(hc.answer_header, '[cC]ontent%-[lL]ength: *(%d+)')
			local size_code_num = tonumber(string.format('%.2f', x/1024))
			if size_code_num <= size_min or size_code_num >= size_max then
				set_var('for_saving', 'no')
				set_var('limit_var', 'yes')
				if size_code_num < size_min then
					table.insert(data.monitor_string_array, {priority=1, text='No saved: min limit is: '..size_min..' kB (file size: '..num_repack(size_code_num)..')'})
					set_color({153, 0, 0}, 1)
				else
					table.insert(data.monitor_string_array, {priority=1, text='No saved: max limit is: '..size_max..' kB (file size: '..num_repack(size_code_num)..')'})
					set_color({153, 0, 0}, 1)
				end
				hc.action = 'dont_save'
			end
		end
	end
end