

local bombCount = 60

local grid = {}

local width,height = 20,20

local font = love.graphics.newFont(12)

local bigFont = love.graphics.newFont(40)

local gameOver = false
local finished = false

function love.load()
	for i=1,width do
		grid[i] = {}
		for j=1,height do
			grid[i][j] = {count = 0, bomb = false, open = false, flag = false}
		end
	end
	for i=1,bombCount do
		local x = love.math.random(1,width)
		local y = love.math.random(1,height)
		if grid[x][y].bomb then
			i = i - 1
		else
			grid[x][y].bomb = true
			if grid[x-1] and grid[x-1][y-1] then grid[x-1][y-1].count = grid[x-1][y-1].count + 1 end
			if grid[x-1] and grid[x-1][y] then grid[x-1][y].count = grid[x-1][y].count + 1 end
			if grid[x-1] and grid[x-1][y+1] then grid[x-1][y+1].count = grid[x-1][y+1].count + 1 end
			if grid[x] and grid[x][y+1] then grid[x][y+1].count = grid[x][y+1].count + 1 end
			if grid[x+1] and grid[x+1][y+1] then grid[x+1][y+1].count = grid[x+1][y+1].count + 1 end
			if grid[x+1] and grid[x+1][y] then grid[x+1][y].count = grid[x+1][y].count + 1 end
			if grid[x+1] and grid[x+1][y-1] then grid[x+1][y-1].count = grid[x+1][y-1].count + 1 end
			if grid[x] and grid[x][y-1] then grid[x][y-1].count = grid[x][y-1].count + 1 end
		end
	end

end

function love.draw()
	love.graphics.setFont(font)
	
	for i,v in pairs(grid) do
		for j,k in pairs(v) do
			love.graphics.setColor(92,92,92,255)
			love.graphics.rectangle("line",(i-1)*20-0.5,(j-1)*20-0.5,20.5,20.5)
			if k.open or (gameOver and k.bomb) then
				if k.bomb then
					love.graphics.setColor(255,0,0,255)
					local w = font:getWidth("X")
					love.graphics.print("X",(i-1)*20+(20-w)/2,(j-1)*20+(20-12)/2)
				else
					love.graphics.setColor(255,255,255,255)
					local count = k.count == 0 and " " or k.count
					local w = font:getWidth(tostring(count))
					love.graphics.print(tostring(count),(i-1)*20+(20-w)/2,(j-1)*20+(20-12)/2)
				end
			else
				love.graphics.setColor(192,192,192,255)
				love.graphics.rectangle("fill",(i-1)*20+0.5,(j-1)*20+0.5,19.5,19.5)
				if k.flag then
					love.graphics.setColor(255,0,0,255)
					local w = font:getWidth("F")
					love.graphics.print("F",(i-1)*20+(20-w)/2,(j-1)*20+(20-12)/2)
				end
			end
		end
	end

	local ww,wh = love.graphics.getDimensions()
	love.graphics.setFont(bigFont)
	if gameOver then
		local w = bigFont:getWidth("Game over")
		local x,y = (ww-w)/2,(wh-bigFont:getHeight())/2
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill",x,y,w,bigFont:getHeight())
		love.graphics.setColor(255,0,0,255)
		love.graphics.print("Game over",x,y)
	elseif finished then
		local w = bigFont:getWidth("Game finished")
		local x,y = (ww-w)/2,(wh-bigFont:getHeight())/2
		love.graphics.setColor(0,0,0,255)
		love.graphics.rectangle("fill",x,y,w,bigFont:getHeight())
		love.graphics.setColor(0,255,0,255)
		love.graphics.print("Game finished",x,y)
	end
end

function love.update(dt)
	local all = true
	for i,v in pairs(grid) do
		for j,k in pairs(v) do
			if k.bomb and not k.flag then
				all = false
				break
			end
		end
	end

	if all then
		finished = true
	end
end

function love.mousepressed(x,y,button)
	if finished or gameOver then return end
	local x = math.ceil(x / 20)
	local y = math.ceil(y / 20)
	if grid[x] and grid[x][y] then
		if button == 1 then
			if not grid[x][y].open and not grid[x][y].flag then
				grid[x][y].open = true
				if grid[x][y].count == 0 and not grid[x][y].bomb then
					local dat = {}
					for i=x-1,x+1 do
						if grid[i] then
							for j=y-1,y+1 do
								if grid[i][j] and not grid[i][j].open then
									table.insert(dat,{x=i,y=j})
								end
							end
						end
					end
					while true do
						local pos = table.remove(dat)
						if pos then
							if grid[pos.x] and grid[pos.x][pos.y] and not grid[pos.x][pos.y].open and not grid[pos.x][pos.y].bomb then
								grid[pos.x][pos.y].open = true
								if grid[pos.x][pos.y].count == 0 then
									local x,y = pos.x,pos.y
									for i=x-1,x+1 do
										if grid[i] then
											for j=y-1,y+1 do
												if grid[i][j] and not grid[i][j].open then
													
													table.insert(dat,{x=i,y=j})
												end
											end
										end
									end
								end 
							end
						else
							break
						end
					end
				elseif grid[x][y].bomb then
					gameOver = true
				end
			end
		elseif button == 2 then
			grid[x][y].flag = not grid[x][y].flag
		end
	end
end

function love.keypressed(key)
	if finished or gameOver and key == "return" then
		love.load()
		finished = false
		gameOver = false
	end
end