local player1 = { piece = 'x', cells = {}, wins = 0 }
local player2 = { piece = 'o', cells = {}, wins = 0 }
local drawCount = 0
local isPlayer1Turn = true
local shouldIgnoreClicks = false
local timer = { total = 2, current = 0, callback = function() end, isRunning = false }
local alignments = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 }, { 1, 4, 7 }, { 2, 5, 8 }, { 3, 6, 9 }, { 1, 5, 9 }, { 3, 5, 7 } }

function love.load()
    love.graphics.setNewFont(30)
end

function love.update(deltaTime)

    update_timer(timer, deltaTime)

    if not timer.isRunning then
        check_game_over()
    end

end

function love.draw()

    draw_grid()
    draw_score()

end

function love.mousepressed(x, y, button, istouch)

    if shouldIgnoreClicks then
        return
    end

    if button == 1 then
      local cell = get_cell_index_by_position(x, y)

        if cell ~= nil and player1.cells[cell] == nil and player2.cells[cell] == nil then
            if isPlayer1Turn then
                player1.cells[cell] = 1
            else
                player2.cells[cell] = 1
            end

            isPlayer1Turn = not isPlayer1Turn
        end
    end
end

function get_cell_index_by_position(x, y)
    local row = 0
    local col = 0

    if x >= 0 and x <= 300 then
        if x <= 100 then
            col = 1
        elseif x <= 200 then
            col = 2
        else
            col = 3
        end
    else
        col = nil
    end

    if y >= 0 and y <= 300 then
        if y <= 100 then
            row = 0
        elseif y <= 200 then
            row = 1
        else
            row = 2
        end
    else
        row = nil
    end

    if row == nil or col == nil then
        return nil
    end

    return row * 3 + col 
end

function reset_board()
    player1.cells = {}
    player2.cells = {}
    isPlayer1Turn = true
    shouldIgnoreClicks = false
end

function count(table)
    local count = 0
    for _ in pairs(table) do 
        count = count + 1 
    end
    return count
end

function update_timer(timer, deltaTime)
    if not timer.isRunning then
        return
    end

    timer.current = timer.current + deltaTime

    if timer.current >= timer.total then
        timer.callback()
        timer.current = 0
    end
end

function check_game_over()
    local is_over, result = is_game_over()

    if is_over then
        shouldIgnoreClicks = true
        timer.callback = function() reset_board(); timer.isRunning = false; end
        timer.isRunning = true
    
        if result == 0 then
            drawCount = drawCount + 1
        elseif result == 1 then
            player1.wins = player1.wins + 1
        else
            player2.wins = player2.wins + 1
        end
    end
end

function is_game_over()
    if count(player1.cells) + count(player2.cells) == 9 then
        return true, 0
    elseif has_three_aligned(player1) then
        return true, 1
    elseif has_three_aligned(player2) then
        return true, 2
    else
        return false
    end
end

function has_three_aligned(player)
    for k,v in pairs(alignments) do
        if player.cells[v[1]] == 1 and player.cells[v[2]] == 1 and player.cells[v[3]] == 1 then
            return true
        end 
    end

    return false
end

function draw_grid()
    for y = 1, 3 do
        for x = 1, 3 do
            local pieceSize = 100
            local pieceDrawSize = pieceSize - 1

            if (((y - 1) * 3) + x) % 2 == 0 then
                piece = 'o'
            end

            love.graphics.setColor(.4, .1, .6)
            love.graphics.rectangle(
                'fill',
                (x - 1) * pieceSize,
                (y - 1) * pieceSize,
                pieceDrawSize,
                pieceDrawSize
            )

            love.graphics.setColor(1, 1, 1)
            if player1.cells[(((y - 1) * 3) + x)] ~= nil then
                love.graphics.print(
                    player1.piece,
                    (x - 1) * pieceSize + 45,
                    (y - 1) * pieceSize + 45
                )
            elseif player2.cells[(((y - 1) * 3) + x)] ~= nil then
                love.graphics.print(
                    player2.piece,
                    (x - 1) * pieceSize + 45,
                    (y - 1) * pieceSize + 45
                )
            end
        end
    end
end

function draw_score()

    love.graphics.print('Player 1 wins : ' .. player1.wins, 400, 85)
    love.graphics.print('Player 2 wins : ' .. player2.wins, 400, 135)
    love.graphics.print('Draws : ' .. drawCount, 400, 185)

end