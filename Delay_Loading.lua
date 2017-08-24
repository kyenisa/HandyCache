--[[ <HCExtension>
@name			Delay Loading
@author			truefriend-cz
@version		1.1
@description	Script for Dealy loadind data from internet (must use with truefriend-cz script pack only) - Extension list position priority: 5
@license		CC BY-NC-SA (Attribution-NonCommercial-ShareAlike - https://creativecommons.org/licenses/by-nc-sa/)
@event			AnswerHeaderReceived
</HCExtension> ]]

function AnswerHeaderReceived()

	local sleep_interval = 0.5 -- limit as sec.

	if hc.cache_file_name == '' and for_saving == 'yes' or afs_var == 'yes' then
		local function set_var(x, y)
			_G[x] = y
		end
		if re.match(file_type_group, [[(Image)]]) then
			local data = MY_EXTENSION_DATA[hc.monitor_index]
			set_var('delay_var', 'yes')
			sleep_interval_num=sleep_interval*1000
			hc.sleep(sleep_interval_num)
			table.insert(data.monitor_string_array, {priority=510, text='Delay: '..sleep_interval..' sec.'})
		end
	end
end