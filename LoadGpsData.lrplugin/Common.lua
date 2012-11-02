--[[
        Common.lua
        
        Namespace shared by more than one plugin module.
        
        This can be upgraded to be a class if you prefer methods to static functions.
        Its generally not necessary though unless you plan to extend it, or create more
        than one...
--]]

local Common, dbg = Object.register( "Common" )




--  Sort array of id keys by encounter count (most encounters first).
--
function Common._sortByEncounters( keys, tbl )
    local function sort( one, two )
        if tbl[one].encounters > tbl[two].encounters then
            return true
        else
            return false
        end    
    end
    table.sort( keys, sort )
end



--  Sort array of id keys by name (alphabetically ascending).
--
function Common._sortByName( keys, tbl )
    local function sort( one, two )
        if tbl[one].name < tbl[two].name then
            return true
        else
            return false
        end    
    end
    table.sort( keys, sort )
end





---     Synopsis:           Parse exiftool -l -X output into a table.
--<br>      
--<br>      Notes:              to use:
--<br>                          if metadata-enabled then
--<br>                              get-metadata from photo
--<br>                              if metadata-from-photo not equal to metadata-from-file (same key) then
--<br>                                  save photo to-do item as update function.
--<br>      
--<br>      Returns:            meta-tbl, errm
--<br>      
--<br>                          table output format:
--<br>                              key:   GroupDerivation_NameDerivation
--<br>                              value(array): UI Name, value for photo
--<br>      
function Common._getFormattedExif( exifPath, photoPath, fmtPath, tbl )

    local id, idpfx, nmpfx, errm
    
    local exeCmd
    local exeFile = app:getGlobalPref( 'exifToolExe' )
    if str:is( exeFile ) then
        app:logVerbose( "Using custom configured exiftool: ^1", exeFile )
    else
        if WIN_ENV then
            exeFile = LrPathUtils.child( _PLUGIN.path, "exiftool.exe" )
            app:logVerbose( "Using built-in exiftool - if not working: try installing your own and browse to it in plugin manager." ) -- path comes in command below.
        elseif MAC_ENV then
            exeFile = "exiftool" -- rely on OS finding it
            app:logVerbose( "Using exiftool that should have been installed by user - if not working, browse to select absolute path in plugin manager." )
        else
            error( "invalid environment" ) -- never happens.
        end
    end
    local sts, cmdOrMsg, data = app:executeCommand( exeFile, "-l -X", { photoPath }, exifPath, 'del' ) -- use 'get' to return response without deleting output file.
    if sts then
        app:logVerbose( "Exif obtained by command: " .. cmdOrMsg )
    else
        return nil, "Error executing command: " .. str:to( cmdOrMsg )
    end

    local xtbl = xml:parseXml( data )

    local goodStuff = xtbl[2][1]
    
    for i = 1, #goodStuff do
    
        repeat
    
            local stuff = goodStuff[i]
            -- _debugTrace( "stf: ", stuff )
            
            local label = stuff.label -- for messages
            local group = stuff.ns
            local compName = stuff.name
            
            if not str:is( group ) or not str:is( compName ) then
                -- _debugTrace( "no group or compName, label: ", str:to( label ) )
                break
            end
            
            -- local text = stuff[1] or ''
            
            local child_1 = stuff[1]
            local child_2 = stuff[2]
            -- local child_3 = stuff[3]
    
            local friendlyName
            local text
            
            if child_1 and child_2 then
                friendlyName = child_1[1]
                text = child_2[1]
            else
                -- _debugTrace( "no child1 or child2, label: ", str:to( label ) )
                break
            end
            
            if friendlyName == nil or type (friendlyName ) ~= 'string' then
                -- _debugTrace( "friendly name funky, label: ", str:to( label ) )
                break
            end
            
            if text == nil then
                -- _debugTrace( "text value nil, label: ", str:to( label ) )
                text = ''
            elseif type( text ) ~= 'string' then
                -- _debugTrace( "text value not string, label: ", str:to( label ) )
                break
            end
            
            
            local bin = text:find( '(Binary', 1, true )
            if bin and bin == 1 then
                -- _debugTrace( "binary, label: ", str:to( label ) )
                break -- ignore binary metadata
            end
            
            local name, value -- return table elements
            
            -- assure first char is a letter.
            local firstLetter = group:find( "%a" )
            if firstLetter == nil then
                app:logInfo( "Ignoring group with no letters: " .. group )
                break
            elseif firstLetter == 1 then
                -- ok as is
            else
                group = group:sub( firstLetter )
                if str:is( group ) then
                    -- ok now
                else
                    app:logInfo( "Ignoring strange group: " .. group )
                    break
                end
            end
                
            id = LOC( "$$$/X=^1_^2", string.gsub( group, "[^%w_]", "" ), string.gsub( compName, "[^%w_]", "" ) ) -- must be letters, numbers, & underscores only (starting with a letter),
                -- to be usable as a pref ID.
            name = friendlyName
            tbl[id] = { name, text }
        until true
    end
        
    return true
    
end


function Common._rozeberSouradnici( soustr )
  local stup, min, vter = string.match(soustr, "^ *([%d-]+) *deg *(%d+)&#39; *([%d.]+)&quot; *$" );
  if stup and min and vter then
    --app:logInfo( str:fmt( "Rozebrano: ^1°^2'^3\" = ", stup, min, vter, sou) )
    local sou = stup + min / 60 + vter / 3600
    return sou
  else
    return nil  
  end
end


---     Synopsis:           Adds exif-table to metadatabase.
--<br>      
--<br>      Notes:              saves corresponding database and metadata-definition in prefs.
--<br>      
--<br>      Returns:            nNew
--
function Common._processExifTable( photo, exifTbl, call, new ) -- ###3 raw-meta?
    
    local latitudeStr = exifTbl.GPS_GPSLatitude
    local longitudeStr = exifTbl.GPS_GPSLongitude 
    local souOrig = photo:getRawMetadata("gps")
    if latitudeStr and longitudeStr then            
      local sou = { latitude = Common._rozeberSouradnici(latitudeStr[2]),
                    longitude  = Common._rozeberSouradnici(longitudeStr[2])
                  }
       app:logInfo( str:fmt( "   ... souradnice: lat=^1  lon=^2", sou.latitude, sou.longitude ))

       if not souOrig then 
         app:logInfo( str:fmt( "   ... souradnice se nastavuji NIC ==> [^3 , ^4] ", sou.latitude, sou.longitude ))           
         photo:setRawMetadata("gps", sou)
         call.nNastavujeSe = call.nNastavujeSe + 1           
       elseif     math.abs(souOrig.latitude  - sou.latitude) < 0.000000001 
          and math.abs(souOrig.longitude - sou.longitude) < 0.000000001  then
         app:logInfo( str:fmt( "   ... souradnice jsou aktualizovane" ))          
         call.nAktualni = call.nAktualni + 1 
       else
         app:logInfo( str:fmt( "   ... souradnice se nastavuji [^1 , ^2] ==> [^3 , ^4] ", souOrig.latitude, souOrig.longitude, sou.latitude, sou.longitude ))
         photo:setRawMetadata("gps", sou)
         call.nPrepisujeSe = call.nPrepisujeSe + 1           
       end  
          
    else
       if souOrig then
         app:logInfo( str:fmt( "   ... fotka neobsahuje souradnice, ale katalog jo" ))
         call.nJenKatalog = call.nJenKatalog + 1           
       else    
         app:logInfo( str:fmt( "   ... fotka neobsahuje souradnice a katalog take ne" ))
         call.nNicNic = call.nNicNic + 1           
       end  
                  
    end
end




--- Update one photo's exif metadata.
--
--  @param      photo (lr-photo, required) the photo to update.
--  @param      call (call or service, required) the call object wrapper.
--  @param      new (array, required) for appending newly discovered metadata items.
--
--  @usage      throws error if problems
--
--  @return     nNew - number of new items discovered.
--
function Common.update1Photo( photo, call, new ) -- ###3 raw-meta? ets
    
    app:logInfo( "Fotka: ".. str:to( photo ) )

    local photoPath = photo:getRawMetadata( 'path' ) -- ###3 raw-meta?
    local fmt = photo:getRawMetadata( 'fileFormat' ) -- ###3 raw-meta?
    if not LrFileUtils.exists( photoPath ) then
        call.nMissing = call.nMissing + 1
        return 0
    end
    
    call.todo = {} -- to-do functions for this photo.

    local exifFileName = str:getBaseName( photoPath ) .. ".exif-meta.xml" -- best if not same suffix as nx-tooey.
    -- local exifPath = LrPathUtils.child( LrPathUtils.parent( photoPath ), exifFileName ) -- use same folder as photo.
    local exifPath
    local exifDir
    local exifTempDir = app:getPref( 'exifTempDir' )
    if str:is( exifTempDir ) then
        if LrPathUtils.isAbsolute( exifTempDir ) then
            if fso:existsAsDir( exifTempDir ) then
                app:logVerbose( "using custom temp dir for exiftool output" ) -- dir is evident by command executed
                exifDir = exifTempDir
            else
                app:logError( "temp dir specified absolutely does not exist (^1) - dir for exiftool output is defaulting to same as photo", exifDir )
            end
        else
            exifDir = LrPathUtils.getStandardFilePath( exifTempDir )
            if fso:existsAsDir( exifDir ) then
                app:logVerbose( "using custom temp dir specified as '^1' for exiftool output", exifTempDir ) -- dir is evident by command executed
            else
                app:logError( "temp dir specified as standard file path name does not exist (^1) - dir for exiftool output is defaulting to same as photo", exifTempDir )
            end
        end
    else
        app:logVerbose( "temp dir for exiftool output is defaulting to same as photo" )
    end
    if exifDir == nil then
        exifDir = LrPathUtils.parent( photoPath )
    end
    local exifPath = LrPathUtils.child( exifDir, exifFileName )
    local fmtFileName = str:getBaseName( photoPath ) .. ".exif-meta.lua"
    local fmtPath = LrPathUtils.child( LrPathUtils.parent( photoPath ), fmtFileName )
    local exifTbl = {}
    local targets = {}
    local xmpSpec = app:getPref( 'xmpHandling' ) or 'rawOnly'
    if fso:existsAsFile( photoPath ) then
        if fmt == 'RAW' then
            if xmpSpec == 'rawOnly' then
                targets = { photoPath }
            else
                local xmpPath = LrPathUtils.replaceExtension( photoPath, 'xmp' )            
                if fso:existsAsFile( xmpPath ) then
                    if xmpSpec == 'rawPri' then
                        targets = { xmpPath, photoPath }
                    elseif xmpSpec == 'xmpPri' then
                        targets = { photoPath, xmpPath }
                    elseif xmpSpec == 'xmpOnly' then
                        targets = { xmpPath }
                    else
                        app:error( "Invalid value for xmp handling" )
                    end
                else
                    -- Could make a fuss, or not...
                    targets = { photoPath }
                end
            end
        else
            targets = { photoPath }
        end
    else
        if fmt == 'RAW' then
            local xmpPath = LrPathUtils.replaceExtension( photoPath, 'xmp' )
            if fso:existsAsFile( xmpPath ) then
                app:logWarning( "Raw photo is missing (^1), but xmp sidecar is present: ^2", photoPath, LrPathUtils.leafName( xmpPath ) )
                return 0
            else
                app:logWarning( "Raw photo is missing (^1), no xmp sidecar either: ^2", photoPath, LrPathUtils.leafName( xmpPath ) )
                return 0
            end
        else
            app:logWarning( "Photo is missing (^1)", photoPath )
            return 0
        end
    end
    for i, path in ipairs( targets ) do
        app:log( path )
        local sts, errm = Common._getFormattedExif( exifPath, path, fmtPath, exifTbl ) -- deletes temp files.
        if sts then
            -- good
        else
            -- app:logError( "no exif table, error message: " .. str:to( errm ) )
            app:error( "Unable to get formatted exif metadata from file (^1), error message: ^2", path, str:to( errm ) )
        end
    end
    Common._processExifTable( photo, exifTbl, call, new )
    
    
end

function Common.updatePhoto( photo, call, new ) -- ###3 raw-meta? ets
    local sts, msg = cat:update( 50, "GPS load from one foto",  function (context, phase)
      Common.update1Photo(photo, call, new )
    end)  
    if sts then
        app:log( "There were no catalog update errors." ) -- catalog may not have actually been updated, but presently the change count is not available in this context. logged stats should elaborate.
    else
        app:logError( "Catalog update error, message: " .. str:to( msg ) )
        call:abort( "Unable to update catalog." )
    end
end

---     Synopsis:           Updates exif metadata for selected photos.
--<br>      
--<br>      Notes:              Errors occuring in update-photo function are trapped and presented generally to the user, who can chooses to keep going or toss in the towel.
--<br>      
--<br>      Returns:            Nothing.
--
function Common.updatePhotos( call, new )

    local pcallStatus, nNewOrErrMsg
    local nNew
    local errm
    local enough
    local nToDo

    -- Note: update-func is called from Lightroom context, and critical variables must be in local function context.
    local photos = call.photos
    assert( photos and #photos > 1, "bad call" ) -- call single photo updater if only one photo.
    local limit = 1000
    local progressScope = call.scope
    nToDo = #photos
    
    local rawMeta = catalog:batchGetRawMetadata( photos, { 'path' } )
    
    local updateFunc = function( context, phase )
        local i1 = ( phase - 1 ) * limit + 1
        local i2 = math.min( phase * limit, nToDo )
        app:logVerbose( "Updating photos from ^1 to ^2", i1, i2 )
        local yc = 0
        for i = i1, i2 do
            local photo = photos[i]
            local photoPath = rawMeta[photo].path
            pcallStatus, nNewOrErrMsg = LrTasks.pcall( Common.update1Photo, photo, call, new )
            if pcallStatus then
                nNew = nNewOrErrMsg
                progressScope:setCaption( str:fmt( "^1 discovered...", str:plural( i, "new item" ) ) )
            else
                errm = nNewOrErrMsg
                app:logError( "Unable to update metadata for " .. photoPath .. ", error message: " .. str:to( errm ) ) -- catalog read-access not required @3.0.
            end
            if call:isQuit( progressScope ) then
                return true -- done, no error.
            else
                progressScope:setPortionComplete( i, nToDo )
                yc = app:yield( yc ) -- yield every 20.
            end            
        end
        if i2 < nToDo then
            return false -- continue next phase.
        end
    end -- end-of-function-definition.

    local sts, msg = cat:update( 50, "GPS load from " .. str:to(nToDo) .. " fotos",  updateFunc )
    if sts then
        app:log( "There were no catalog update errors." ) -- catalog may not have actually been updated, but presently the change count is not available in this context. logged stats should elaborate.
    else
        app:logError( "Catalog update error, message: " .. str:to( msg ) )
        call:abort( "Unable to update catalog." )
    end
    
end



return Common
