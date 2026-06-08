---@dependency apis
trace = CONSOLE.traceback
logg = CONSOLE.log
warnn = CONSOLE.warn
errr = CONSOLE.err
dbgg = CONSOLE.debug
exposeToGlobal({
    trace = trace,
    logg = logg,
    warnn = warnn,
    errr = errr,
    dbgg = dbgg
})
timer.delay(function()
require "apis"
require "uiapis"
end)