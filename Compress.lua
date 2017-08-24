--[[ <HCExtension>
@name			Compress
@author			truefriend-cz
@version		1.1
@description	Script for Compressing saving data (must use with truefriend-cz script pack only) - Extension list position priority: 6
@license		CC BY-NC-SA (Attribution-NonCommercial-ShareAlike - https://creativecommons.org/licenses/by-nc-sa/)
@event			Timer1m
@event			AnswerHeaderReceived
@event			BeforeAnswerHeaderSend
@event    		Destroy
</HCExtension> ]]

function Timer1m()
	hc.shell_execute('cmd', '/C del "'..hc.cache_path..[[!Temp_for_compress\]]..'*.*" /F /S /Q /A: R /A: H /A: A', nil, 'SW_HIDE')
	hc.sleep (1000)
	hc.shell_execute('cmd', '/C rmdir /s /q "'..hc.cache_path..'!Temp_for_compress"', nil, 'SW_HIDE')
end

function AnswerHeaderReceived()
	if for_saving == 'yes' then
		local function set_var(x, y)
			_G[x] = y
		end
		local compress_types = [[(jpg|jpeg|png|js|css)]]
		if re.match(file_type, compress_types) and limit_var ~= 'yes' then
			local data = MY_EXTENSION_DATA[hc.monitor_index]
			table.insert(data.monitor_string_array, {priority=700, text='Compressed'})
			set_var('compress_var', 'yes')
		end
	end	
end

function BeforeAnswerHeaderSend()
	if compress_var == 'yes' and for_saving == 'yes' and hc.cache_file_name ~= '' then
		for first, second, third in string.gmatch(hc.url, "(%a+)://(.+)/([^/]+)$") do
			local second = second:gsub([[/]], [[\]])
			compress_path = hc.cache_path..'!Temp_for_compress'..[[\]]..first..[[\]]..second..[[\]]
			compress_path_file = hc.cache_path..'!Temp_for_compress'..[[\]]..first..[[\]]..second..[[\]]..third..'.bat'
		end
		hc.prepare_path(compress_path)
		local file = io.open(compress_path_file, 'w') 
		if file then
			file:write('@echo off', '\n')
			file:write('', '\n')
			file:write('ping 127.0.0.1 -n 2 >NUL 2>&1', '\n')
			if file_type == 'jpg' or file_type == 'jpeg' then
				file:write('"'..hc.ini_path..[[Utils\Compress\Plugins\magick.exe]]..'" "'..hc.cache_file_name..'" '..[[-sampling-factor 4:2:0 -strip -quality 30 -interlace JPEG -colorspace sRGB]]..' "'..hc.cache_file_name..'"', '\n')
			end
			if file_type == 'png' then
				file:write('"'..hc.ini_path..[[Utils\Compress\Plugins\magick.exe]]..'" "'..hc.cache_file_name..'" '..[[-colors 256 -quality 30 -depth 8 -define png:compression-level=9 -define png:compression-filter=0 -define png:compression-strategy=0 -strip -type PaletteAlpha]]..' "'..hc.cache_file_name..'"', '\n')
			end
			if file_type == 'js' or file_type == 'css' then
				file:write('"'..hc.ini_path..[[Utils\Java\bin\java.exe]]..'" -jar "'..hc.ini_path..[[Utils\Compress\YUI_Compressor\yuicompressor.jar]]..'" "'..hc.cache_file_name..'" '..[[-o]]..' "'..hc.cache_file_name..'"', '\n')
			end
			file:write('', '\n')
			file:write('exit')
			file:flush()
			file:close()
			hc.shell_execute(compress_path_file, nil, nil, 'SW_HIDE')
		end
	end
end

function Destroy()
	hc.shell_execute('cmd', '/C del "'..hc.cache_path..[[!Temp_for_compress\]]..'*.*" /F /S /Q /A: R /A: H /A: A', nil, 'SW_HIDE')
	hc.sleep (1000)
	hc.shell_execute('cmd', '/C rmdir /s /q "'..hc.cache_path..'!Temp_for_compress"', nil, 'SW_HIDE')
end
