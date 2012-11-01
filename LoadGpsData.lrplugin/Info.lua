--[[
        Info.lua
--]]

return {
    appName = "LoadGpsData",
    author = "Martin Veverka",
    authorsWebsite = "www.geokuk.cz",
    platforms = { 'Windows', 'Mac' },
    pluginId = "cz.geokuk.lightroom.LoadGpsData", -- used for update checking only.
    xmlRpcUrl = "http://www.robcole.com/Rob/_common/cfpages/XmlRpc.cfm",
    donateUrl = "http://www.robcole.com/Rob/Donate",
    LrPluginName = "Load GPS data from file to catalog",
    LrSdkMinimumVersion = 3.0,
    LrSdkVersion = 4.0,
    LrPluginInfoUrl = "http://www.robcole.com/Rob/ProductsAndServices/ExifMetaLrPlugin",
    LrToolkitIdentifier = "cz.geokuk.lightroom.LoadGpsData",
    --LrPluginInfoProvider = "ExtendedManager.lua",
    LrInitPlugin = "Init.lua",
    LrShutdownPlugin = "Shutdown.lua",
    LrEnablePlugin = "Enable.lua",
    LrDisablePlugin = "Disable.lua",
    LrHelpMenuItems = {
        title = "Reload",
        file = "Reload.lua",
    },
    LrExportMenuItems = {
        {
            title = "&Nacti GPS data do vybranych fotek (modifies catalog only)",
            file = "Update.lua",
        },
    },
    VERSION = { display = "5.1    Build: 2012-09-12 03:57:28" },
}
