--[[ <HCExtension>
@name			Processor
@author			truefriend-cz
@version		1.1
@description	Script for Main operations (must use with truefriend-cz script pack only) - Extension list position priority: 1
@license		CC BY-NC-SA (Attribution-NonCommercial-ShareAlike - https://creativecommons.org/licenses/by-nc-sa/)
@event			BeforeViewInMonitor
@event			RequestHeaderReceived
@event			AnswerHeaderReceived
@event			BeforeAnswerHeaderSend
</HCExtension> ]]

local function set_var(x, y)
	_G[x] = y
end

function BeforeViewInMonitor()
	if hc.method == 'POST' then
		hc.action = 'dont_update'
		set_var('post', 'yes')
		do return end
	end

	local type_exclude = re.find(hc.url, [[\.(htm|html|php|php3|php5|asp|aspx|txt)(\?|$)]], 1)
	if type_exclude then
		type_define = 'Excluded: '..type_exclude
		set_var('accept', 'exclude')
		do return end
	end

	file_type = {}
	local name_type = 'Image'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(jpg|jpeg|bmp|png|webp|gif|svg)(\?|$)]]
	local name_type = 'Video'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(mp4|flv|mpg)(\?|$)]]
	local name_type = 'Style'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(css)(\?|$)]]
	local name_type = 'Javascript'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(js)(\?|$)]]
	local name_type = 'Database'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(db)(\?|$)]]
	local name_type = 'Icon'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(ico)(\?|$)]]
	local name_type = 'Compress'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(zip|rar)(\?|$)]]
	local name_type = 'Audio'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(mp3)(\?|$)]]
	local name_type = 'Video - fragmented'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(ts)(\?|$)]]
	local name_type = 'Flash'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(swf)(\?|$)]]
	local name_type = 'Font'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(woff|woff2|ttf)(\?|$)]]
	local name_type = 'Eset'
	file_type[name_type] = {}
	file_type[name_type].extension = [[\.(nup)(\?|$)]]
	local name_type = 'AVG'
	file_type[name_type] = {}
	file_type[name_type].extension = [[.*avg.*\.(bin)(\?|$)]]
	
	for i, v in pairs(file_type) do
		if re.match(hc.url, v.extension) then
			local a = re.find (hc.url, v.extension, 1)
			type_define = i..': '..a
			set_var('file_type_group', i)
			set_var('file_type', a)
			set_var('accept', 'yes')
		end
	end

end

function set_color(color, priority)
	local data = MY_EXTENSION_DATA[hc.monitor_index]

	local function rgb(r, g, b)
		return r + g*256 + b*256*256
	end

	if not data.color_priority or priority < data.color_priority then
		data.color = rgb(table.unpack(color))
		data.color_priority = priority
	end
end

function RequestHeaderReceived()
	MY_EXTENSION_DATA = MY_EXTENSION_DATA or {}
	MY_EXTENSION_DATA[hc.monitor_index] = { monitor_string_array={} }
	local data = MY_EXTENSION_DATA[hc.monitor_index]

	if hc.cache_file_name == '' and accept == 'yes' and accept ~= 'exclude' then
		set_var('for_saving', 'yes')
	else
		hc.action = 'dont_update'
		set_var('for_saving', 'no')
	end
	
end


function AnswerHeaderReceived()
	local data = MY_EXTENSION_DATA[hc.monitor_index]

	if hc.cache_file_name == '' and accept == 'yes' and accept ~= 'exclude' then
		hc.action = 'save'
		set_var('for_saving', 'yes')
	end

end

function BeforeAnswerHeaderSend()
	local data = MY_EXTENSION_DATA[hc.monitor_index]

	local function monitor_show(monitor_string, monitor_color)
		hc.monitor_string = monitor_string
		if monitor_color then
			hc.monitor_text_color = monitor_color
		end
	end

	if post == 'yes' then
		table.insert(data.monitor_string_array, {priority=40, text='(Post)'})
		set_color({102, 51, 0}, 1000)
	end
	if accept == 'yes' or accept == 'exclude' then
		table.insert(data.monitor_string_array, {priority=5, text='('..type_define..')'})
		set_color({124, 124, 124}, 300)
	end
	if accept ~= 'yes' and post ~= 'yes' and accept ~= 'exclude' and accept ~= 'clear' then
		table.insert(data.monitor_string_array, {priority=5, text='Object do not defined for processing'})
		set_color({124, 124, 124}, 10)
	end
	if for_saving == 'yes' then
		table.insert(data.monitor_string_array, {priority=11, text='Saved to Cache'})
		set_color({51, 170, 255}, 20)
	end

	if accept ~= 'clear' then
		name_header = {}
		local header_string = 'Load from Cache'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++200\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 10
		name_header[header_string].color = {102, 150, 0}

		local header_string = 'Switching protocols'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++101\s]]
		name_header[header_string].priority = 100
		name_header[header_string].color = {0, 153, 0}

		local header_string = 'Connection Closed'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++Client\s*disconnected\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 100
		name_header[header_string].color = {0, 153, 0}

		local header_string = 'Connection Closed'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++Stop\s*command\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 100
		name_header[header_string].color = {0, 153, 0}

		local header_string = 'Load from Cache Incomplete'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++206\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 12
		name_header[header_string].color = {0, 153, 0}

		local header_string = 'Incomplete/Ignore'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++206\s(?!.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 13
		name_header[header_string].color = {0, 153, 0}

		local header_string = 'Redirected HC'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++302\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 14
		name_header[header_string].color = {255, 128, 0}

		local header_string = 'Moved permanently'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++301\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 15
		name_header[header_string].color = {255, 128, 0}

		local header_string = 'Client Cache'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++304\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 16
		name_header[header_string].color = {153, 153, 0}

		local header_string = 'Not modified'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++304\s*+Not\s*+Modified\s]]
		name_header[header_string].priority = 100
		name_header[header_string].color = {124, 124, 124}

		local header_string = 'No Content'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++204\s]]
		name_header[header_string].priority = 1
		name_header[header_string].color = {153, 0, 0}

		local header_string = 'No authorized'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++401\s(?!.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 1
		name_header[header_string].color = {153, 0, 0}

		local header_string = 'No authorized'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++403\s(?!.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 1
		name_header[header_string].color = {153, 0, 0}

		local header_string = 'Blocked by HC'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++403\s(.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 1
		name_header[header_string].color = {153, 0, 0}

		local header_string = 'No exist'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++404\s(?!.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 1
		name_header[header_string].color = {153, 0, 0}

		local header_string = 'Bad Gateway'
		name_header[header_string] = {}
		name_header[header_string].definition = [[\A\S++\s++502\s(?!.*?^Server:\s*+HandyCache)]]
		name_header[header_string].priority = 1
		name_header[header_string].color = {153, 0, 0}

		for i, v in pairs(name_header) do
			if re.match(hc.answer_header, v.definition) then
				table.insert(data.monitor_string_array, {priority=v.priority, text=i})
				set_color(v.color, v.priority)
			end
		end

		if re.find(hc.answer_header, [[^Content-Encoding:\s*+((x-)?compress|deflate|(x-)?gzip)]]) then
			table.insert(data.monitor_string_array, {priority=1000, text='('..re.substr(1)..')'})
			set_color({102, 51, 0}, 1000)
		end
	end

	table.sort(data.monitor_string_array,
		function(record1, record2)
			return record1.priority <= record2.priority
		end
	)

	local texts = {}
	for i,record in ipairs(data.monitor_string_array) do
		texts[i] = record.text
	end

	local delimiter = ' - ||| - '
	monitor_show(table.concat(texts, delimiter), data.color)
end