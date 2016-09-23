local skynet = require "skynet"
local filelog = require "filelog"
local msghelper = require "gatesvrmsghelper"
local base = require "base"
local msgproxy = require "msgproxy"
local filename = "gatesvrcmd.lua"
local GatesvrCMD = {}

function GatesvrCMD.process(session, source, event, ...)
	local f = GatesvrCMD[event] 
	if f == nil then
		filelog.sys_error(filename.."Gatesvrd GatesvrCMD.process invalid event:"..event)
		return nil
	end
	f(...)
end

function GatesvrCMD.start(conf)
	local server = msghelper:get_server()
	server.tcpmng.init(server, "agent", conf.agentsize, conf.agentincr, conf.svr_netpack)
	base.skynet_retpack(skynet.call(server.gate_service, "lua", "open" , conf))
	msghelper:event_process("lua", "notice", "get_gatesvr_state")
end

--[[function GatesvrCMD.close(fd)
	local server = msghelper:get_server()
	server.tcpmng.agentexit(fd)
end]]

--处理agent发起的主动退出
function GatesvrCMD.agentexit(fd, rid)
	local server = msghelper:get_server()
	server.tcpmng.agentexit(fd, rid)
end

--处理玩家心跳超时关闭socket
function GatesvrCMD.heart_timeout(fd)
	local server = msghelper:get_server()
	server.tcpmng.heart_timeout(fd)
end

return GatesvrCMD