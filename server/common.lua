CLX = {}
CLX.Players = {}
CLX.UsableItemsCallbacks = {}
CLX.Items = {}
CLX.ServerCallbacks = {}
CLX.TimeoutCount = -1
CLX.CancelledTimeouts = {}
CLX.Pickups = {}
CLX.PickupId = 0
CLX.Jobs = {}
CLX.RegisteredCommands = {}

AddEventHandler('clx:getSharedObject', function(cb)
	cb(CLX)
end)

function getSharedObject()
	return CLX
end

MySQL.ready(function()
	MySQL.Async.fetchAll('SELECT * FROM items', {}, function(result)
		for k,v in ipairs(result) do
			CLX.Items[v.name] = {
				label = v.label,
				weight = v.weight,
				rare = v.rare,
				canRemove = v.can_remove
			}
		end
	end)

	MySQL.Async.fetchAll('SELECT * FROM jobs', {}, function(jobs)
		for k,v in ipairs(jobs) do
			CLX.Jobs[v.name] = v
			CLX.Jobs[v.name].grades = {}
		end

		MySQL.Async.fetchAll('SELECT * FROM job_grades', {}, function(jobGrades)
			for k,v in ipairs(jobGrades) do
				if CLX.Jobs[v.job_name] then
					CLX.Jobs[v.job_name].grades[tostring(v.grade)] = v
				else
					print(('[clx_core] [^3WARNING^7] Ignoring job grades for "%s" due to missing job'):format(v.job_name))
				end
			end

			for k2,v2 in pairs(CLX.Jobs) do
				if CLX.Table.SizeOf(v2.grades) == 0 then
					CLX.Jobs[v2.name] = nil
					print(('[clx] [^3WARNING^7] Ignoring job "%s" due to no job grades found'):format(v2.name))
				end
			end
		end)
	end)

	print('[clx_core] [^2INFO^7] CLX developed by CLX-Org has been initialized')
end)

RegisterServerEvent('clx:clientLog')
AddEventHandler('clx:clientLog', function(msg)
	if Config.EnableDebug then
		print(('[clx_core] [^2TRACE^7] %s^7'):format(msg))
	end
end)

RegisterServerEvent('clx:triggerServerCallback')
AddEventHandler('clx:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	CLX.TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('clx:serverCallback', playerId, requestId, ...)
	end, ...)
end)
