--[[
        Update.lua
        
        Handles "Update" file menu item.
--]]


local Update = {} -- register the name of this item in init.lua for conditional dbg support via plugin manager.


local dbg = Object.getDebugFunction( 'Update' )



--- Update target photos.
--
--  @usage      Menu handling function.
--
function Update.main()
    app:call( Service:new{ name="Update Photos", async=true, guard=App.guardVocal, main=function( call )
        local s, m = background:pause() -- must be called from async task.
        if s then
            app:log( "Background process paused." )
        else
            app:show{ warning="Unable to pause background task. Update will proceed despite this anomaly, but you should definitely report this problem!" }
        end
        local photos = catalog:getTargetPhotos() -- whole filmstrip if none selected - returns empty table not nil if no photos.
        if #photos == 0 then
            app:show{ warning="No photos to update." }
            return
        elseif #photos == 1 then
            if not dia:isOkOrDontAsk( "Update 1 selected photo?", "Update 1 photo" ) then
                return
            end
            -- proceed w/ 1 selected photo.
            app:log( "Updating 1 selected photo." )            
        else
            local photo = catalog:getTargetPhoto()
            if photo then -- at least one is selected
                local answer = app:show{ confirm="Update ^1, or just the one most selected?",
                    buttons={ dia:btn( "All Selected", 'ok' ), dia:btn( "Just One", 'other' ) },
                    subs = { str:plural( #photos, "selected photo", true ) },
                    actionPrefKey = "Confirm update of one vs all selected",
                }
                if answer == 'ok' then -- all selected
                    -- proceed with filmstrip photos.
                    app:log( "Updating filmstrip." )            
                elseif answer == 'other' then -- just one
                    photos = { photo }
                    app:log( "Updating most-selected photo." )            
                elseif answer == 'cancel' then -- cancel
                    call:cancel()
                    return
                else
                    error( "bad answer" )
                end
            else -- nothing is selected, so consider whole catalog, or filmstrip.
                local allPhotos = catalog:getAllPhotos()
                local title
                local answer = app:show{ confirm="Update ^1 in whole catalog, or ^2 in filmstrip?",
                    subs = { str:plural( #allPhotos, "photo", 1 ), str:plural( #photos, "photo", 1 ) },
                    buttons = { dia:btn( "Whole Catalog", 'other' ), dia:btn( "Filmstrip", 'ok' ) },
                    actionPrefKey = "Update whole catalog or filmstrip",
                }
                if answer == 'ok' then
                    -- photos = photos
                    app:log( "Updating filmstrip." )            
                else
                    photos = allPhotos
                    app:log( "Updating whole catalog." )            
                end
            end
        end
        call.photos = photos
        call.scope = LrProgressScope {
            title = str:fmt( "LoadGpsData Update (^1)", str:plural( #call.photos, "target", true ) ),
            functionContext = call.context,        
        }
        local new = {}
        local nNew

        call.nNastavujeSe = 0           
        call.nAktualni = 0 
        call.nPrepisujeSe = 0           
        call.nJenKatalog = 0           
        call.nNicNic = 0           
        
        call.nMissing = 0
        if #call.photos > 1 then
            app:log( "^1 to do.", str:plural( #call.photos, "photo" ) )
            Common.updatePhotos( call, new )
            nNew = tab:countItems( new )
        else
            nNew = Common.updatePhoto( call.photos[1], call, new )
        end
    end, finale=function( call )
        background:continue()
        app:log( "^1 missing.", str:plural( call.nMissing, "photo", true ) )

        app:log( "^1 fotek - nastavovany souradnice.", call.nNastavujeSe )
        app:log( "^1 fotek - prepisovany souradnice jinymi.", call.nPrepisujeSe )
        app:log( "^1 fotek - souradnise jsou aktualni.", call.nAktualni )
        app:log( "^1 fotek - ani v katalogu ani ve fotce.", call.nNicNic )
        app:log( "^1 fotek - v katalogu souradnice jsou, ve fotce ne.", call.nJenKatalog )

    end } )
end



Update.main()
