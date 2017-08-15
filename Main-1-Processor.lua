--[[ <HCExtension>
@name			Main 1 - Processor
@author			JVProducciones based, truefriend-cz
@version		1
@event			Init/init
@event			BeforeViewInMonitor/one -- types
@event			RequestHeaderReceived/two -- useragent
@event          BeforeRequestHeaderSend/three -- stamp
@event			AnswerHeaderReceived/four -- request
@event			BeforeAnswerHeaderSend/monitor -- monitor
</HCExtension> ]]

function init()
--	hc.put_msg(1, 'Main OK init')
--hc.put_msg(1, 'Test OK')
end

function get_info_header_answer_code()
	_,_,x = string.find(hc.answer_header, 'HTTP/1%.%d +(%d+)')
	answer_code = tonumber(x)
	return answer_code
end

function get_info_header_server_code()
	answer = [[^Server: HandyCache[^\r\n]+]]
	if re.match(hc.answer_header, answer) then
		server_code = re.find(hc.answer_header, answer, 1)
		hc.set_global('server_code', server_code)
		return server_code
	end
end

function get_info_header_encoding_code()
	encoding = [[^Content-Encoding:\s*+((x-)?compress|deflate|(x-)?gzip)]]
	if re.match(hc.answer_header, encoding) then
		encoding_code = re.find(hc.answer_header, encoding, 1)
		hc.set_global('encoding_code', encoding_code)
		return encoding_code
	end
end
	
function get_info_header_size_code_num()
	_,_,x = string.find(hc.answer_header, '[cC]ontent%-[lL]ength: *(%d+)')
	size_code = tonumber(x)
	size_code_num = (size_code)/1000
	size_code_num = format_num(size_code_num, 2)
	hc.set_global('size_code_num', size_code_num)
	return size_code_num
end

function format_num(num, numdecimal)
	mult = 10^(numdecimal or 0)
	return math.floor(num * mult) / mult
end

function rgb(r, g, b)
	local r = r
	local g = g*256
	local b = b*256*256
	return r+g+b
end

function check_yes(b)
	return b == 'yes'
end
function check_no(c)
	return c == 'no'
end

function check_empty(d)
	return d == '' or d == nil
end

function check_full(e)
	return e ~= '' or e == nil
end

function monitor_show()
	if check_full(monitor_string) then
		hc.monitor_string = monitor_string
	end
	if check_full(monitor_color) then
		hc.monitor_text_color = monitor_color
	end
end

function monitor_add_color(f)
	if check_empty(monitor_color) then
		return f
	else
		return monitor_color
	end
end

function monitor_add_string(d)
	delimiter = ' - ||| - '
	if check_empty(monitor_string) then
		return d
	else
		return delimiter..d
	end
end

function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then
		io.close(f)
		return true
	else
		return false
	end
end

function sort_table(t, f)
	local a = {}
	for n in pairs(t) do
		table.insert(a, n)
	end
	table.sort(a, f)
	local i = 0
	local iter = function()
	i = i + 1
	if a[i] == nil then
		return nil
    else
		return a[i], t[a[i]]
	end
	end
	return iter
end

function check_allowed()
	if check_yes(accept) and check_yes(for_saving) and check_no(for_loading_from_cache) and check_accessed() then
		if check_yes(limit_var) then
			return false
		end
		return true
	else
		return false
	end
end

function one()
	delimiter = ' - ||| - '
	accept = ''
	excluded = ''
	post = ''
	monitor_string = ''
	monitor_color = ''
	monitor_string_array = {}
	monitor_color_array = {}
	
	type_database = [[\.(db)(\?|$)]]
	type_video = [[\.(mp4|flv|mpg)(\?|$)]]
	type_style = [[\.(css)(\?|$)]]
	type_javascript = [[\.(js)(\?|$)]]
	type_image = [[\.(jpg|jpeg|bmp|png|webp|gif|svg)(\?|$)]]
	type_icon = [[\.(ico)(\?|$)]]
	type_compress = [[\.(zip|rar)(\?|$)]]
	type_audio = [[\.(mp3)(\?|$)]]
	type_video_frag = [[\.(ts)(\?|$)]]
	type_flash = [[\.(swf)(\?|$)]]
	type_font = [[\.(woff|woff2|ttf)(\?|$)]]
	type_eset = [[\.(nup)(\?|$)]]
	type_avg = [[.*avg.*\.(bin)(\?|$)]]
	type_eset = [[\.(nup)(\?|$)]]
	type_exclude = [[\.(htm|html|php|php3|php5|asp|aspx|txt)(\?|$)]]

	if hc.method == 'POST' then
		hc.action = 'dont_update'
		post = 'yes'
	end
	if re.match (hc.url, type_database) then
		type_extension = re.find (hc.url, type_database, 1)
		type_define = 'Database: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_video) then
		type_extension = re.find (hc.url, type_video, 1)
		type_define = 'Video: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_style) then
		type_extension = re.find (hc.url, type_style, 1)
		type_define = 'Style: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_javascript) then
		type_extension = re.find (hc.url, type_javascript, 1)
		type_define = 'Javascript: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_image) then
		type_extension = re.find (hc.url, type_image, 1)
		type_define = 'Image: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_icon) then
		type_extension = re.find (hc.url, type_icon, 1)
		type_define = 'Icon: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_compress) then
		type_extension = re.find (hc.url, type_compress, 1)
		type_define = 'Compress: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_audio) then
		type_extension = re.find (hc.url, type_audio, 1)
		type_define = 'Audio: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_video_frag) then
		type_extension = re.find (hc.url, type_video_frag, 1)
		type_define = 'Video - Fragmented: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_flash) then 	
		type_extension = re.find (hc.url, type_flash, 1)
		type_define = 'Flash: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_font) then
		type_extension = re.find (hc.url, type_font, 1)
		type_define = 'Font: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_eset) then
		type_extension = re.find (hc.url, type_eset, 1)
		type_define = 'Eset: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_avast) then
		type_extension = re.find (hc.url, type_avast, 1)
		type_define = 'Avast: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_avg) then
		type_extension = re.find (hc.url, type_avg, 1)
		type_define = 'AVG: '..type_extension
		accept = 'yes'
	end
	if re.match (hc.url, type_exclude) then
		type_extension = re.find (hc.url, type_exclude, 1)
		type_define = 'Excluded: '..type_extension
		accept = 'no'
	end
	if not check_accessed() then
		accept = 'no'
	end

	hc.set_global('type_define', type_define)
	hc.set_global('type_extension', type_extension)
	hc.set_global('accept', accept)
	hc.set_global('post', post)
	hc.set_global('excluded', excluded)
end

function two()
	accept = hc.get_global('accept')
	post = hc.get_global('post')
	excluded = hc.get_global('excluded')

	if check_yes(accept) and check_accessed() then
		for_loading_from_cache = 'no'
		if check_full(hc.cache_file_name) then
			hc.action = 'dont_update'
			for_saving = 'no'
			for_loading_from_cache = 'yes'
		else
			hc.action = 'save'
			for_saving = 'yes'
		end
	else
		hc.action= 'dont_save'
		for_saving = 'no'
	end

	hc.set_global('for_loading_from_cache', for_loading_from_cache)
	hc.set_global('for_saving', for_saving)
end

function three()
	-- Comment
--	for_saving = 'no'
end

function four()
	-- Comment
end

function monitor()
	type_define = hc.get_global('type_define')
	accept = hc.get_global('accept')
	post = hc.get_global('post')
	excluded = hc.get_global('excluded')
	for_saving = hc.get_global('for_saving')

	if check_yes(post) then
		table.insert(monitor_string_array, 300, '(Post)')
		table.insert(monitor_color_array, 300, rgb(102, 51, 0))
	end
	if check_yes(accept) or check_no(accept) then
		table.insert(monitor_string_array, 100, '('..type_define..')')
	end
	if check_accessed() then
		if check_yes(for_saving) then
			table.insert(monitor_string_array, 200, 'Saved to Cache')
			table.insert(monitor_color_array, 200, rgb(51, 170, 255))
		end
		if check_no(accept) then 
			table.insert(monitor_color_array, 200, rgb(124, 124, 124))
		end
		if check_empty(accept) then
			if not check_yes(post) then
			table.insert(monitor_string_array, 101, 'Object do not defined for processing')
			table.insert(monitor_color_array, 101, rgb(124, 124, 124))
			end
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s200[^\r\n]+]]) and re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) then
			table.insert(monitor_string_array, 201, 'Load from Cache')
			table.insert(monitor_color_array, 201, rgb(0, 204, 0))
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s403[^\r\n]+]]) and re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) then
			table.insert(monitor_string_array, 301, 'Blocked by HC')
			table.insert(monitor_color_array, 301, rgb(153, 0, 0))
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s101[^\r\n]+]]) and re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) then
			table.insert(monitor_string_array, 302, 'Switching protocols')
			table.insert(monitor_color_array, 302, rgb(0, 153, 0))
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s206[^\r\n]+]]) and re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) and not re.match(hc.url, [[^.*/videoplayback\?]]) then
			table.insert(monitor_string_array, 303, 'Load from Cache Incomplete')
			table.insert(monitor_color_array, 303, rgb(0, 153, 0))
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s206[^\r\n]+]]) and not re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) then
			table.insert(monitor_string_array, 304, 'Incomplete/Ignore')
			table.insert(monitor_color_array, 304, rgb(0, 153, 0))
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s302[^\r\n]+]]) and re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) then
			table.insert(monitor_string_array, 305, 'Redirected HC')
			table.insert(monitor_color_array, 305, rgb(255, 128, 0))
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s301[^\r\n]+]]) and re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) then
			table.insert(monitor_string_array, 306, 'Moved permanently')
			table.insert(monitor_color_array, 306, rgb(255, 128, 0))
		end
		if re.match(hc.answer_header, [[^HTTP/1\.1\s304[^\r\n]+]]) and re.match(hc.answer_header, [[^Server: HandyCache[^\r\n]+]]) then
			table.insert(monitor_string_array, 307, 'Client Cache')
			table.insert(monitor_color_array, 307, rgb(153, 153, 0))
		end
	end
	if re.match(hc.answer_header,[[^Content-Encoding:\s*+((x-)?compress|deflate|(x-)?gzip)]]) then
		type_encoding = re.find (hc.answer_header, [[^Content-Encoding:\s*+((x-)?compress|deflate|(x-)?gzip)]], 1)
		table.insert(monitor_string_array, 400, type_encoding)
		table.insert(monitor_color_array, 400, rgb(102, 51, 0))
	end

	for string_number, string_text in sort_table(monitor_string_array) do
		monitor_string = monitor_string..monitor_add_string(string_text)
	end
	for string_number, string_color in sort_table(monitor_color_array) do
		monitor_color = monitor_add_color(string_color)
	end
	monitor_show()
end
