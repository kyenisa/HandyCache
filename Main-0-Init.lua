--[[ <HCExtension>
@name			Main 0 - Init
@author			truefriend-cz
@version		1
@event			Init/zero_init
@event			BeforeViewInMonitor/zero_one
</HCExtension> ]]

function zero_init()
--	hc.put_msg(1, 'Main 0 OK init')
--hc.put_msg(1, 'Test OK')
end

function zero_one()
	hc.call_me_for('AnswerHeaderReceived', 'get_info_header_answer_code')
end

function get_info_header_answer_code()
	_,_,x = string.find(hc.answer_header, 'HTTP/1%.%d +(%d+)')
	answer_code = tonumber(x)
end

function check_accessed()
	if answer_code == 401 or answer_code == 403 or answer_code == 404 or answer_code == 502 then
		if answer_code == 401 and server_code ~= 'HandyCache' then
			table.insert(monitor_string_array, 99, 'No authorized')
			table.insert(monitor_color_array, 99, rgb(153, 0, 0))
		end
		if answer_code == 403 and server_code ~= 'HandyCache' then
			table.insert(monitor_string_array, 98, 'No authorized')
			table.insert(monitor_color_array, 98, rgb(153, 0, 0))
		end
		if answer_code == 404 and server_code ~= 'HandyCache' then
			table.insert(monitor_string_array, 97, 'No exist')
			table.insert(monitor_color_array, 97, rgb(153, 0, 0))
		end
		if answer_code == 502 and server_code ~= 'HandyCache' then
			table.insert(monitor_string_array, 96, 'Bad Gateway')
			table.insert(monitor_color_array, 96, rgb(153, 0, 0))
		end
		return false
	else
		return true
	end
end
