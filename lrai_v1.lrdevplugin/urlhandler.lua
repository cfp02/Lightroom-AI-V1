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


-- Returning a table that contains the URLHandler function
return {
    URLHandler = function(url)
        -- Remove double quotes if present at the beginning and the end of the URL
        url = url:gsub('^"(.*)"$', '%1')

        -- Log the received URL for debugging purposes
        logMessage("URL received: " .. url)

        -- Example of parsing the URL and performing actions based on its contents
        -- You can add more complex parsing logic here depending on your needs
        local command, param = url:match("lightroom://com.coleparks.lrai_v1/(%w+)%?(%w+)")
        if command and param then
            logMessage("Command: " .. command .. ", Parameter: " .. param)
            -- Perform actions based on command and parameter
            -- This is where you would add the logic to interact with Lightroom API or perform other tasks
            LrTasks.startAsyncTask(function()
                local catalog = LrApplication.activeCatalog()
                catalog:withWriteAccessDo("Adjust Develop Setting", function()
                    LrDevelopController.setValue(command, tonumber(param))
                end)
            end)
        else
            logMessage("Invalid URL format received, these are command and params received: " .. tostring(command) .. ", " .. tostring(param))
        end
    end
}
