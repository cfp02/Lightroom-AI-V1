local LightroomAI = require 'LightroomAI'

return {
    URLHandler = function(url)
        -- Assuming URL is in the format: lightroom://com.coleparks.lrai_v2/(%w+)%?(%w+)
        local setting, value, operation = url:match("lightroom://com.coleparks.lrai_v2/(%w+)%?(%w+)%?(%w+)")
        if setting and value then
            LightroomAI:enqueueCommand({ setting = setting, value = value, operation = operation or "set" })
            LightroomAI:logMessage("URL processed: " .. url)
        else
            LightroomAI:logMessage("Invalid URL format received: " .. url)
        end
    end
}
