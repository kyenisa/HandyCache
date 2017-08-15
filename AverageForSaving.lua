--[[ <HCExtension>
@name			Average for saving
@author			truefriend-cz
@version		1
@event			Init/afs_init
@event			BeforeViewInMonitor/afs_one
</HCExtension> ]]

function afs_init()
--	hc.put_msg(1, 'Afs OK init')
--hc.put_msg(1, 'Test OK')
end

function file_make(path_file)
	hc.shell_execute('cmd', '/C md "'..afs_path..'"', nil, 'SW_HIDE', true)
	local file = io.open(path_file, 'w') 
	if file then
		file:write(code)
		file:flush()
		file:close()
	end
	file_content = file_open(path_file)
end

function file_open(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

function afs_show()
	table.insert(monitor_string_array, 4, 'AvgFS: '..file_content..'/'..limit..' hits')
	table.insert(monitor_color_array, 4, rgb(197, 105, 255))
end

function afs_one()
	accept = hc.get_global('accept')
	for_saving = hc.get_global('for_saving')
	for_loading_from_cache = hc.get_global('for_loading_from_cache')
	
	type_define = hc.get_global('type_define')

	hc.call_me_for('AnswerHeaderReceived', 'afs_answer')
end

function afs_answer()
	afs_var = 'no'
	limit = '9'
	cache_path = hc.cache_path
	cache_path_afs = '!Average_for_saving'
	for first, second, third in string.gmatch(hc.url, "(%a+)://(.+)/([^/]+)$") do
		second = second:gsub([[/]], [[\]])
		afs_path = cache_path..cache_path_afs..[[\]]..first..[[\]]..second
		afs_path_file = cache_path..cache_path_afs..[[\]]..first..[[\]]..second..[[\]]..third..'.log'
		afs_path_file_yes = cache_path..cache_path_afs..[[\]]..first..[[\]]..second..[[\]]..third..'_yes.log'
	end
	if check_allowed() then
		if re.match(type_define, [[(Image|Icon|Style|Javascript|Font)]], 1) then
			if not file_exists(afs_path_file_yes) then
				afs_var = 'yes'
				hc.set_global('afs_var', afs_var)
				if file_exists(afs_path_file) then
					file_content = file_open(afs_path_file)
					if file_content < limit then
						hc.action = 'dont_save'
						accept = 'no'
						for_saving = 'no'
						hc.set_global('accept', accept)
						hc.set_global('for_saving', for_saving)
						code = file_content+1
						file_make(afs_path_file)
						afs_show()
					else
						hc.action = 'save'
						accept = 'yes'
						for_saving = 'yes'
						hc.set_global('accept', accept)
						hc.set_global('for_saving', for_saving)
						os.remove (afs_path_file)
						file_make(afs_path_file_yes)
--						afs_show()
					end
				else
					hc.action = 'dont_save'
					accept = 'no'
					for_saving = 'no'
					hc.set_global('accept', accept)
					hc.set_global('for_saving', for_saving)
					code = '1'
					file_make(afs_path_file)
					afs_show()
				end
			end
		end
	end
	if file_exists(hc.cache_file_name) and not file_exists(afs_path_file_yes) then
		file_make(afs_path_file_yes)
	end
	hc.set_global('accept', accept)
	hc.set_global('for_saving', for_saving)
end
