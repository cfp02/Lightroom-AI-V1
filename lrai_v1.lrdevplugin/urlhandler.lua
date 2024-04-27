local LrLogger = import 'LrLogger'
local LrDevelopController = import 'LrDevelopController'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'

local myLogger = LrLogger('URLHandlerLogger') -- Create a logger with a unique name for this handler
myLogger:enable("logfile") -- Log output to file, you can change this to "print" during development for console output

-- Custom function to log messages
local function logMessage(message)
    myLogger:trace(message) -- Using trace level for detailed debug info, you can also use info, warn, etc.
end

local commandQueue = {}
local isProcessing = false

local processQueue -- Forward declaration to allow mutual recursion

logMessage("urlhandler.lua loaded")

-- Function to execute commands from the queue
local function executeCommand(command)
    LrTasks.startAsyncTask(function()
        local catalog = LrApplication.activeCatalog()
        catalog:withWriteAccessDo("Execute Plugin Command", function()
            LrDevelopController.setValue(command.setting, command.value)
            logMessage("Executed command: " .. command.setting .. " = " .. tostring(command.value))
        end)
        LrTasks.yield()  -- Yield to allow other tasks to run
        
    end)
    isProcessing = false
    processQueue()  -- Check if there are more commands to process
end


-- Function to process the queue
processQueue = function()
    if not isProcessing and #commandQueue > 0 then
        isProcessing = true
        local command = table.remove(commandQueue, 1)
        executeCommand(command)
    -- else
    --     isProcessing = false
    end
end

local function makeQueueString(queue)
    local str = ""
    for i, command in ipairs(queue) do
        str = str .. command.setting .. " = " .. tostring(command.value) .. ", "
    end
    return str
end


-- Function to add commands to the queue
local function enqueueCommand(command)
    table.insert(commandQueue, command)
    logMessage("Command enqueued. Queue length: " .. #commandQueue .. ", Command: " .. command.setting .. " = " .. tostring(command.value) .. ", Queue: " .. makeQueueString(commandQueue) .. ", isProcessing: " .. tostring(isProcessing))
    if not isProcessing then
        logMessage("Not processing, calling processQueue having just added the command: " .. command.setting .. " = " .. tostring(command.value))
        processQueue()  -- Trigger processing if not already running
    end
end



-- URL Handler that parses commands from URLs and adds them to the queue
return {
    URLHandler = function(url)
        -- Assuming URL is in the format: lightroom://com.coleparks.lrai_v1/(%w+)%?(%w+)
        local setting, value = url:match("lightroom://com.coleparks.lrai_v1/(%w+)%?(%w+)")
        if setting and value then
            enqueueCommand({ setting = setting, value = tonumber(value) })
            logMessage("URL processed: " .. url)
        else
            logMessage("Invalid URL format received: " .. url)
        end
    end
}
