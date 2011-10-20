local M = {}

debugContext = UI.CreateContext("MinUI Debug Context")
textFrames = {}
debugFrame = nil
methodsToShow = 12

profiling = false

--
-- Setup the Frames
--
local function setup()
	if(profiling)then
		--
		-- Create the Debug Frame
		--
		debugFrame = UI.CreateFrame("Frame","MinUI Debug Window", debugContext)
		debugFrame:SetPoint("TOPLEFT",debugContext, "TOPLEFT", 0, 0 )
		debugFrame:SetWidth(500)
		debugFrame:SetHeight(310)
		debugFrame:SetBackgroundColor(0,0,0,0.5)
		debugFrame:SetLayer(10)
		debugFrame:SetVisible(true)
		
		-- title text
		titleText = UI.CreateFrame("Text","MinUI Debug Title", debugFrame)
		titleText:SetFontSize(14)
		titleText:SetText("MinUI BroFiler")
		titleText:SetHeight(titleText:GetFullHeight())
		titleText:SetWidth(titleText:GetFullWidth())
		titleText:SetPoint("TOPCENTER",debugFrame, "TOPCENTER", 0,0 )
		titleText:SetVisible(true)
			
				
		-- title text
		keyText = UI.CreateFrame("Text","MinUI Debug Key", debugFrame)
		keyText:SetFontSize(14)
		keyText:SetText("| # | function name | high | low | avg |")
		keyText:SetHeight(keyText:GetFullHeight())
		keyText:SetWidth(keyText:GetFullWidth())
		keyText:SetPoint("TOPLEFT",debugFrame, "TOPLEFT", 5, titleText:GetFullHeight() )
		keyText:SetVisible(true)
			
			
		function debugFrame.Event:LeftDown()
			self.MouseDown = true
			mouseData = Inspect.Mouse()
			self.MyStartX = debugFrame:GetLeft()
			self.MyStartY = debugFrame:GetTop()
			self.StartX = mouseData.x - self.MyStartX
			self.StartY = mouseData.y - self.MyStartY
			tempX = debugFrame:GetLeft()
			tempY = debugFrame:GetTop()
			tempW = debugFrame:GetWidth()
			tempH =	debugFrame:GetHeight()
			debugFrame:ClearAll()
			debugFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", tempX, tempY)
			debugFrame:SetWidth(tempW)
			debugFrame:SetHeight(tempH)
			debugFrame:SetBackgroundColor(1,0,0,0.5)
		end

		function debugFrame.Event:MouseMove()
			if self.MouseDown then
				local newX, newY
				mouseData = Inspect.Mouse()
				newX = mouseData.x - self.StartX
				newY = mouseData.y - self.StartY
				debugFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", newX, newY)
			end
		end

		function debugFrame.Event:LeftUp()
			if self.MouseDown then
				self.MouseDown = false
							
				-- store frame placement in saved var
				debugFrame.x = debugFrame:GetLeft()
				debugFrame.y = debugFrame:GetTop()
				
				debugFrame:SetBackgroundColor(0,0,0,0.5)
			end
		end

		local yOffset = titleText:GetFullHeight() + keyText:GetFullHeight()
		--
		-- create text frames for top ten items
		--
		for i=1,methodsToShow do
			textFrames[i] = UI.CreateFrame("Text","MinUI Text Item " .. i, debugFrame)
			textFrames[i]:SetFontSize(14)
			textFrames[i]:SetText("---")
			textFrames[i]:SetHeight(textFrames[i]:GetFullHeight())
			textFrames[i]:SetWidth(textFrames[i]:GetFullWidth())
			textFrames[i]:SetPoint("TOPLEFT",debugFrame, "TOPLEFT", 5, yOffset + ((i-1)*textFrames[i]:GetFullHeight()) )
			textFrames[i]:SetVisible(true)
		end
	end
end

--
-- Update the calls, total time, average time values of the method
--
local function update ( methodName )
	if(profiling)then
		--print ("updating ", methodName)
		local lastEndTimeMillis = (M[methodName].lastEndTime/1000)
		local lastStartTimeMillis = (M[methodName].lastStartTime/1000)
		local timeTaken = (lastEndTimeMillis - lastStartTimeMillis)
		--print ("Time Taken for ", methodName, " = ", timeTaken)
		
		-- if we get 0 time difference, just assume a 1ms delay for the purpose of trying to find bottlenecks
		if(timeTaken == 0)then
			timeTaken = 1 -- 1 ms
		end
		
		M[methodName].lastTime = timeTaken
		
		--print("time taken ", methodName,timeTaken)
		
		if (timeTaken > M[methodName].highestTime) then
			M[methodName].highestTime = timeTaken
		end
		
		if (timeTaken < M[methodName].lowestTime) then
			M[methodName].lowestTime = timeTaken
		end
		
		M[methodName].totalTime = M[methodName].totalTime + timeTaken
		M[methodName].averageTime = M[methodName].totalTime / M[methodName].calls
		
		-- sort methods by highestTime/peak time
		table.sort(M, 
			function(a,b) return a.highestTime > b.highestTime end
		)
		
		-- update top ten texts
		local count = 1
		for methodName,debugValues in pairs(M) do
			if(count <= methodsToShow)then
				if( debugValues.totalTime > 0 )then
					local text = string.format("| %d | %s | %dms | %dms | %dms |",count, methodName,debugValues.highestTime,debugValues.lowestTime, debugValues.averageTime )
					textFrames[count]:SetText(text)
					textFrames[count]:SetHeight(textFrames[count]:GetFullHeight())
					textFrames[count]:SetWidth(textFrames[count]:GetFullWidth())
				end
			end
			
			count = count + 1
		end
	end	
end


--
-- Register the start time of a method (and if it hasn't been registered before, create a new
-- table to hold its values)
--
function functionStart( methodName )
	if(profiling)then
		-- create new method name table
		if not (M[methodName])then
			print("new method registered for debug ", methodName)
			M[methodName] = {}
			M[methodName].calls = 0
			M[methodName].lastStartTime = 0
			M[methodName].lastEndTime = 0
			M[methodName].lastTime = 0
			M[methodName].highestTime = 0
			M[methodName].lowestTime = 0
			M[methodName].totalTime = 0
			M[methodName].averageTime = 0
		end	
		
		M[methodName].calls = M[methodName].calls + 1
		M[methodName].lastStartTime = Inspect.Time.Frame()
	end
end

--
-- Register the end time of a method
--
function functionEnd( methodName )
	if(profiling)then
		M[methodName].lastEndTime = Inspect.Time.Frame()
		-- update the methods debug values
		update ( methodName )
	end
end


--
-- Run Setup
--
setup()

