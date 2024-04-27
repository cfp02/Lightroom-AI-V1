local LrLogger = import 'LrLogger'
local LrDevelopController = import 'LrDevelopController'
local LrApplication = import 'LrApplication'
local LrTasks = import 'LrTasks'

local LightroomAI = {
    commandQueue = {},
    isProcessing = false
}

function LightroomAI:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function LightroomAI:logMessage(message)
    local myLogger = LrLogger('URLHandlerLogger')
    myLogger:enable("logfile") -- Output to file
    myLogger:trace(message)
end

function LightroomAI:enqueueCommand(command)
    table.insert(self.commandQueue, command)
    self:logMessage("Command enqueued. Queue length: " .. #self.commandQueue .. ", Command: " .. command.setting .. " = " .. tostring(command.value))
    if not self.isProcessing then
        self:logMessage("Not processing, calling processQueue")
        self:processQueue()
    end
end

function LightroomAI:executeCommand(command)
    LrTasks.startAsyncTask(function()
        local catalog = LrApplication.activeCatalog()
        catalog:withWriteAccessDo("Execute Plugin Command", function()

            local decodedValue
            if command.value:sub(1, 1) == "N" then
                decodedValue = -tonumber(command.value:sub(2))  -- Negative value
                self:logMessage("Negative value detected: " .. decodedValue)
            elseif command.value:sub(1, 1) == "P" then
                decodedValue = tonumber(command.value:sub(2))  -- Positive value
                self:logMessage("Positive value detected: " .. decodedValue)
            else
                decodedValue = tonumber(command.value)  -- Fallback if no prefix is found
                self:logMessage("No prefix found, using value as is: " .. decodedValue)
            end

            if command.operation == "set" then
                LrDevelopController.setValue(command.setting, decodedValue)
            elseif command.operation == "increment" then
                local currentValue = LrDevelopController.getValue(command.setting)
                LrDevelopController.setValue(command.setting, currentValue + decodedValue)
            end
        end)
        LrTasks.yield()
        self:logMessage("Executed command: " .. command.setting .. " = " .. tostring(command.value) .. " in mode: " .. command.operation)
        self.isProcessing = false
        self:processQueue()
    end)
end

function LightroomAI:processQueue()
    if not self.isProcessing and #self.commandQueue > 0 then
        self.isProcessing = true
        local command = table.remove(self.commandQueue, 1)
        self:executeCommand(command)
    else
        self.isProcessing = false
    end
end

return LightroomAI:new()
