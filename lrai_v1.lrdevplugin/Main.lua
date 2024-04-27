local LrSocket = import 'LrSocket'
local LrTasks = import 'LrTasks'
local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrDevelopController = import 'LrDevelopController'

local function handle_command(command)
    local catalog = LrApplication.activeCatalog()
    catalog:withWriteAccessDo("AdjustPhotoDevelopSettings", function(context)
        if command == "adjust_exposure" then
            LrDevelopController.setValue('Exposure', LrDevelopController.getValue('Exposure') + 0.10)
        elseif command == "adjust_contrast" then
            LrDevelopController.setValue('Contrast', LrDevelopController.getValue('Contrast') + 10)
        -- Add more cases as needed
        end
    end)
end

LrTasks.startAsyncTask(function()
    local server = LrSocket.bind {
        functionContext = LrTasks.activeContext(),
        port = 12345,
        mode = 'receive',
        onMessage = function(message, info)
            LrTasks.startAsyncTask(function()
                handle_command(message)
            end)
        end,
        onError = function(socket, err)
            LrDialogs.showError("Socket Error: " .. err)
        end
    }
end)
