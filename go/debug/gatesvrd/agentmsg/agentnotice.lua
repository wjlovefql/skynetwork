local filelog = require "filelog"
local msghelper = require "agenthelper"
local playerdatadao = require "playerdatadao"
local base = require "base"
require "enum"

local AgentNotice = {}

function AgentNotice.process(session, source, event, ...)
	local f = AgentNotice[event] 
	if f == nil then
		f = AgentNotice["other"]
		f(event, ...)
		return
	end
	f(...)
end


function AgentNotice.other(msgname, noticemsg)
	msghelper:send_noticemsgto_client(nil, msgname, noticemsg)
end

function AgentNotice.standuptable(noticemsg)
	local server = msghelper:get_server()
	if server.rid ~= noticemsg.rid then
		return
	end

	if server.roomsvr_id ~= noticemsg.roomsvr_id then
		return
	end

	if server.roomsvr_table_id ~= noticemsg.roomsvr_table_id then
		return
	end

	if server.roomsvr_seat_index ~= noticemsg.roomsvr_seat_index then
		return
	end
	server.roomsvr_seat_index = 0
end


-- playgame = {
-- 	rid = 0,
-- 	level = 0,   --级位
--     dan = 0,     --段位
--     winnum = 0,  --胜局 
--     losenum = 0, --败局
--     drawnum = 0, --和局
-- }

-- message GameResultNtc{
-- 	optional int32 rid = 1;
-- 	optional int32 roomsvr_seat_index = 2;
-- 	optional int32 win_type = 3;       //输赢类型
-- 	optional int32 win_num = 4;			//胜利目数
-- }
function AgentNotice.gameresult(noticemsg)
	local server = msghelper:get_server()
	local playgame = server.playgame
	if noticemsg.win_type == EWinResult.WIN_RESULT_WIN then
		playgame.winnum = playgame.winnum + 1
	elseif noticemsg.win_type == EWinResult.WIN_RESULT_LOSE then
		playgame.losenum = playgame.losenum + 1
	elseif noticemsg.win_type == EWinResult.WIN_RESULT_DRAW then
		playgame.drawnum = playgame.drawnum + 1
	end
	playerdatadao.save_player_playgame("update",noticemsg.rid,playgame)
end

return AgentNotice