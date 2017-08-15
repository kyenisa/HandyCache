--[[ <HCExtension>
@name			Compress by file type
@author			truefriend-cz
@version		1
@event			Init/compress_init
@event			BeforeViewInMonitor/compress_one
</HCExtension> ]]

function compress_init()
--	hc.put_msg(1, 'Compress OK init')
--hc.put_msg(1, 'Test OK')
end

function compress_one()
	accept = hc.get_global('accept')
	for_saving = hc.get_global('for_saving')
	for_loading_from_cache = hc.get_global('for_loading_from_cache')

	type_extension = hc.get_global('type_extension')

	hc.call_me_for('AnswerHeaderReceived', 'compress_answer')
	hc.call_me_for('BeforeAnswerHeaderSend', 'compress_show')
end

function compress_answer()
	compress_var = 'no'
	if check_allowed() then
		if type_extension=='jpg' then
			compress_show_add()
		end
		if type_extension=='jpeg' then
			compress_show_add()
		end
		if type_extension =='png' then
			compress_show_add()
		end
		if type_extension == 'js' then
			compress_show_add()
		end
		if type_extension == 'css' then
			compress_show_add()
		end
	compress_var = 'yes'
	hc.set_global('compress_var', compress_var)
	end
end

function compress_show()
	if check_allowed() and check_accessed() then
		if type_extension=='jpg' then
			hc.shell_execute(hc.ini_path..[[Utils\Compress\ImageMagick\magick.exe ]], [["]]..hc.cache_file_name..[[" -sampling-factor 4:2:0 -strip -quality 30 -interlace JPEG -colorspace sRGB "]]..hc.cache_file_name..[["]], nil, 'SW_HIDE')
		end
		if type_extension=='jpeg' then
			hc.shell_execute(hc.ini_path..[[Utils\Compress\ImageMagick\magick.exe ]], [["]]..hc.cache_file_name..[[" -sampling-factor 4:2:0 -strip -quality 30 -interlace JPEG -colorspace sRGB "]]..hc.cache_file_name..[["]], nil, 'SW_HIDE')
		end
		if type_extension =='png' then
			hc.shell_execute(hc.ini_path..[[Utils\Compress\ImageMagick\magick.exe ]], [["]]..hc.cache_file_name..[[" -colors 256 -quality 30 -depth 8 -define png:compression-level=9 -define png:compression-filter=0 -define png:compression-strategy=0 -strip -type PaletteAlpha "]]..hc.cache_file_name..[["]], nil, 'SW_HIDE')
		end
		if type_extension == 'js' then
			hc.shell_execute(hc.ini_path..[[Utils\Java\bin\java.exe ]], [[-jar "]]..hc.ini_path..[[Utils\Compress\YUI_Compressor\yuicompressor.jar" "]]..hc.cache_file_name..[[" -o "]]..hc.cache_file_name..[["]], nil, 'SW_HIDE')
		end
		if type_extension == 'css' then
			hc.shell_execute(hc.ini_path..[[Utils\Java\bin\java.exe ]], [[-jar "]]..hc.ini_path..[[Utils\Compress\YUI_Compressor\yuicompressor.jar" "]]..hc.cache_file_name..[[" -o "]]..hc.cache_file_name..[["]], nil, 'SW_HIDE')
		end
	end
end

function compress_show_add()
	table.insert(monitor_string_array, 700, 'Compressed')
end