--[[ <HCExtension>
@name			Average Loading
@author			truefriend-cz
@version		1.1
@description	Script for Average Loading data from internet and saving (must use with truefriend-cz script pack only) - Extension list position priority: 4
@license		CC BY-NC-SA (Attribution-NonCommercial-ShareAlike - https://creativecommons.org/licenses/by-nc-sa/)
@event			AnswerHeaderReceived
</HCExtension> ]]

function AnswerHeaderReceived()
	if for_saving == 'yes' then
		local function set_var(x, y)
			_G[x] = y
		end
		local function file_exists(name)
			local f=io.open(name,"r")
			if f~=nil then
				io.close(f)
				return true
			else
				return false
			end
		end
		local function file_make(path_file)
			hc.prepare_path(afs_path)
			local file = io.open(path_file, 'w') 
			if file then
				file:write(code)
				file:flush()
				file:close()
			end
			file_content = file_open(path_file)
		end
		local function file_open(path)
			local file = io.open(path, "rb") -- r read mode and b binary mode
			local content = file:read "*a" -- *a or *all reads the whole file
			file:close()
			return content
		end
		local limit = '3'
		for first, second, third in string.gmatch(hc.url, "(%a+)://(.+)/([^/]+)$") do
			local second = second:gsub([[/]], [[\]])
			afs_path = hc.cache_path..'!Average_for_saving'..[[\]]..first..[[\]]..second..[[\]]
			afs_path_file = hc.cache_path..'!Average_for_saving'..[[\]]..first..[[\]]..second..[[\]]..third..'.log'
		end
		if re.match(file_type_group, [[(Image|Icon|Style|Javascript|Font)]], 1) then
			local data = MY_EXTENSION_DATA[hc.monitor_index]
			set_var('afs_var', 'yes')
			if file_exists(afs_path_file) then
				file_content = file_open(afs_path_file)
				if file_content < limit then
					hc.action = 'dont_save'
					set_var('for_saving', 'no')
					code = file_content+1
					table.insert(data.monitor_string_array, {priority=500, text='AvgFS: '..code..'/'..limit..' hits'})
					set_color({197, 105, 255}, 2)
					file_make(afs_path_file)
				else
					hc.action = 'save'
					set_var('for_saving', 'yes')
					os.remove(afs_path_file)
				end
			else
				hc.action = 'dont_save'
				set_var('for_saving', 'no')
				code = '1'
				table.insert(data.monitor_string_array, {priority=500, text='AvgFS: '..code..'/'..limit..' hits'})
				set_color({197, 105, 255}, 2)
				file_make(afs_path_file)
			end
		end
	end
end