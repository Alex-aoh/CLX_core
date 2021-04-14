AddEventHandler('clx:getSharedObject', function(cb)
	cb(CLX)
end)

function getSharedObject()
	return CLX
end

AAAAAA