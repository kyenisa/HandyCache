--[[ <HCExtension>
@name			Scheduller - Defrag Cache
@author			mai62, truefriend-cz (formating code and recoding for Cache defragmentation)
@version		0.61
@description	Scheduler for Defrag Cache
@license		CC BY-NC-SA (Attribution-NonCommercial-ShareAlike - https://creativecommons.org/licenses/by-nc-sa/) (only for truefriend-cz edited for this extension)
@event			Init
@event			Timer1m
@event			Options
</HCExtension> ]]

function ini_file_name()
	local fn= hc.script_name
	if not fn or (fn=='') then return [[c:\Defrag.ini]] end
	return re.replace(fn, [[(.*\.).*]], [[\1ini]])
end

function SaveParams()
	local f = assert(io.open(ini_file_name(), 'w'))
	if not f then return end
	f:write('Period='..hc_static['Period']..'\n')
	f:write('LastStart='..hc_static['LastStart']..'\n')
	f:write('NextStart='..hc_static['NextStart']..'\n')
	f:close()
end

function Timer1m()
	t= os.time()
	if hc_static['NextStart'] < t then
		hc_static['LastStart']= t
		hc_static['NextStart']= t+hc_static['Period']*3600
		SaveParams()
		hc.put_msg('The scheduler started the Cache defragmentation...')
		hc.shell_execute([["]]..hc.ini_path..[[Utils\WinContig\WinContig.exe]]..[["]], [["]]..hc.cache_path..[[" /DEFRAG /NOPROMPT /NOSCROLL /CHKDSK:0 /CLEAN:0 /NOGUI]], nil, 'SW_SHOW')
		os.remove(hc.cache_path..[[Defrag_tmp.txt]])
		hc.sleep(1000)
		while true do
			hc.shell_execute([[cmd]], [[/C tasklist /NH /FO CSV /FI "IMAGENAME eq WinContig.exe">"]]..hc.cache_path..[[Defrag_tmp.txt"]], nil, 'SW_HIDE')
			hc.sleep(1000)
			local f = io.open(hc.cache_path..[[Defrag_tmp.txt]], "r")
			local content = f:read()
			f:close()
			if content == [[INFO: No tasks are running which match the specified criteria.]] then
				os.remove(hc.cache_path..[[Defrag_tmp.txt]])
				break
			end
		end
		hc.put_msg('The Cache defragmentation has been completed.')
	end
end

function Init()
	hc.put_to_log('function init is called')
	local f = io.open(ini_file_name(), 'r')
	if f then 
		local s
		local t= {}
		while true do
				s = f:read("*line")
				if s then table.insert(t, s) else break end
		end
		f:close()
		local i
		for i=1, #t do
			s= re.find(t[i],'Period=(.*)',1)
			if s then
				hc_static['Period']= tonumber(s)
			else
				s= re.find(t[i],'LastStart=(.*)',1)
				if s then
					hc_static['LastStart']= tonumber(s)
				else
					s= re.find(t[i],'NextStart=(.*)',1)
					if s then
						hc_static['NextStart']= tonumber(s)
					end
				end
			end
		end
	end
	if not hc_static['Period'] then hc_static['Period']= 72 end
	if not hc_static['LastStart'] then hc_static['LastStart']= 0 end
	if not hc_static['NextStart'] then hc_static['NextStart']= os.time()+hc_static['Period']*3600 end
	if hc_static['LastStart'] == 0 then SaveParams() end
end

function Options()
	require "vcl"
	if Form then
		Form:Free()
		Form=nil
	end
	Form = VCL.Form('Form')
	x,y,w,h= hc.window_pos()
	Form._ = { Caption='Cache Defrag - Settings', width=380, height=160, BorderStyle='Fixed3D' }
	Form._ = { left=x+(w-Form.width)/2, top=y+(h-Form.height)/2 }
	Label1 = VCL.Label(Form,"Label1")
	Label1._ = { caption='Run every ', top=20, left=30, width=200}
	Edit1 = VCL.Edit(Form,"Edit1")
	Edit1._ = { text=hc_static['Period'], parentfont=true, top=17, left=230, width=50, onchange=nil}
	Label2 = VCL.Label(Form,"Label2")
	Label2._ = { caption='hours', top=20, left=290, width=70}
	Label3 = VCL.Label(Form,"Label3")
	Label3._ = { caption='next start: '..hc.systime_to_str(hc_static['NextStart'],false), top=50, left=30, width=300}
	OkButton = VCL.Button(Form, "OkButton")
	OkButton._ = {onclick = "onOkButtonClick", width=100, left=30, caption = "OK", top= Form.clientheight-OkButton.height-10}
	CancelButton = VCL.Button(Form, "CancelButton")
	CancelButton._ = {onclick = "onCancelButtonClick", width=100, left=140, top=OkButton.top, caption = "Cancel"}
	Form:ShowModal()
	Form:Free()
	Form=nil
end

function onOkButtonClick(Sender)
	hc_static['Period']= Edit1.text
	Form:Close()
	hc.put_to_log(hc_static['Period'])
	if hc_static['LastStart'] == 0 then hc_static['LastStart']= os.time() end
	hc_static['NextStart']= hc_static['LastStart'] + hc_static['Period']*3600
	SaveParams()
end

function onCancelButtonClick(Sender)
	Form:Close()
end