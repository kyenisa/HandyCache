--[[ <HCExtension>
@name			Delay Loading
@author			truefriend-cz
@version		1.1
@description	Script for Dealy loadind data from internet (must use with truefriend-cz script pack only) - Extension list position priority: 4
@license		CC BY-NC-SA (Attribution-NonCommercial-ShareAlike - https://creativecommons.org/licenses/by-nc-sa/)
@event			AnswerHeaderReceived
</HCExtension> ]]

function AnswerHeaderReceived()

	local sleep_interval = 0.5 -- limit as sec.

	if for_saving == 'yes' then
		local function set_var(x, y)
			_G[x] = y
		end
		if re.match(file_type_group, [[(Image)]]) then
			sleep_interval_num=sleep_interval*1000
			hc.sleep(sleep_interval_num)
			local data = MY_EXTENSION_DATA[hc.monitor_index]
			table.insert(data.monitor_string_array, {priority=500, text='Delay: '..sleep_interval..' sec.'})
		end
	end
end