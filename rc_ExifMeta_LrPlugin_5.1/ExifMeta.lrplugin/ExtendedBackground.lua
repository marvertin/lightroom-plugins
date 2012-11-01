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



--- Background processing method.
--
--  @param      call object - usually not needed, but its got the name, and context... just in case.
--
function ExtendedBackground:process( call, target )

    local photo
    if not target then -- normal periodic call
        photo = catalog:getTargetPhoto() -- most-selected.
        if photo == nil then
            self:considerIdleProcessing( call )
            return
        end
    else
        photo = target
    end
    
    call.nChanged = 0
    call.nUnchanged = 0
    call.nAlreadyUpToDate = 0
    call.nMissing = 0
    -- call-total-new not updated by update-photo (single).
    call.autoUpdate = true -- just a little flag to keep update-photo from logging a metadata-same message.
    
    local nNew, msg
    local sts, nNewOrMsg = LrTasks.pcall( Common.updatePhoto, photo, call, self.newItems ) -- updates last-update-time if successful.
    if sts then
        if call.nAlreadyUpToDate == 1 then -- nothing much was done, and no new items.
            assert( nNewOrMsg == 0, "new exif metadata for already up2date photo?" )
            if not target then
                self:considerIdleProcessing( call )
            end
            return
        end
        nNew = nNewOrMsg
        if nNew > 0 then
            local totalNew = tab:countItems( self.newItems )
            app:logInfo( str:fmt( "^1 found by auto-check so far.", str:plural( totalNew, " new item" ) ) )
        else
            -- dbg( "no new items" )
        end
    else
        msg = nNewOrMsg
        app:logError( str:to( msg ) )
        app:sleepUnlessShutdown( .5 ) -- take a moment, but not too long...
    end
    
end



return ExtendedBackground
