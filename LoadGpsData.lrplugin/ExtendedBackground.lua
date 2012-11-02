--[[
        ExtendedBackground.lua
--]]

local ExtendedBackground, dbg = Background:newClass{ className = 'ExtendedBackground' }



--- Constructor for extending class.
--
function ExtendedBackground:newClass( t )
    return Background.newClass( self, t )
end



--- Constructor for new instance.
--
function ExtendedBackground:new( t )
    local interval
    local minInitTime
    local idleThreshold
    if app:getUserName() == '_RobCole_' and app:isAdvDbgEna() then
        interval = .1
        idleThreshold = 1
        minInitTime = 3
    else
        interval = .3
        idleThreshold = 3 -- (every third cycle) appx 1/sec.
        -- minInitTime = nil - use default
    end    
    local o = Background.new( self, { interval = interval, minInitTime = minInitTime, idleThreshold=idleThreshold } ) -- default min-init-time is 10-15 seconds or so.
     -- OK to check for changes fairly frequently, since its strictly using dates for update check.
     -- note: if all-photos or selected are also being done, this can still influence CPU significantly.
    o.newItems = {}
    return o
end



--- Initialize background task.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function ExtendedBackground:init( call )
    if app:getUserName() == "_RobCole_" and app:isAdvDbgEna() then
        self.allPhotosIndex = 4299 -- ***
    end
    self.initStatus = true
end



function ExtendedBackground:idleProcess( target, call )
    assert( target ~= nil, "dont call idle process with nil target" )
    self:process( call, target )
end






return ExtendedBackground
