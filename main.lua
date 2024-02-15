
-- Define constants
local GRAVITY = 9.8 -- Gravity value (meters per second squared)
local BALL_RADIUS = 20 -- Radius of the ball (meters)
local FLOOR_HEIGHT = 50 -- Height of the floor (meters)
local BOUNCE_FACTOR = 0.7 -- Factor of restitution (how much velocity is conserved after a bounce)
local ACCELERATION = 500 -- Acceleration value (meters per second squared)
local SCREEN_BORDER = 0.2 -- Border limit on the screen sides (meters)
local JUMP_VELOCITY = -500 -- Initial velocity when jumping (meters per second)
local FRICTION_COEFFICIENT = 0.7 -- Friction coefficient
local SLOPE_ANGLE = math.rad(30) -- Angle of the slope in radians
local SLOPE_LENGTH = 2 -- Length of the slope (meters)
local TEMPERATURE_LIMIT = 100 -- You can adjust this as needed (degrees Celsius)
-- Define Variables
local KINETIC_ENERGY = 0 -- Initialize kinetic energy
local POTENTIAL_ENERGY = 0 -- Initialize potential energy
local TOTAL_ENERGY = 0 -- Initialize total energy
local SAVED_ENERGY = 0 -- Initialize saved energy
local DISSIPATED_ENERGY = 0 -- Initialize dissipated energy
local DISSIPATION_VALUES = "" -- Initialize dissipation values
local ROLLING_FACTOR = 0 -- Initialize rolling factor
local HEAT_FACTOR = 0 -- Initialize heat factor
local VELOCITY_DIR_X = ">"
local VELOCITY_DIR_Y = ">"


-- Variables for ball position, velocity, and acceleration
local ball = {
    x = love.graphics.getWidth() / 2, -- Initial x position at the center of the screen
    y = BALL_RADIUS * 2, -- Initial y position above the screen
    vx = 0, -- Initial velocity in the x direction (meters per second)
    vy = 0, -- Initial velocity in the y direction (meters per second)
    ax = 0, -- Initial acceleration in the x direction (meters per second squared)
    ay = GRAVITY * 51, -- Initial acceleration in the y direction (gravity) (meters per second squared)
    grounded = false, -- Flag to track if the ball is grounded
    mass = 1, -- Mass of the ball (kilograms)
    h = 0 -- Initialize height
}

local SOURCES_OF_DISSIPATION = {

}
local Crisp = require("crisp")
require("slider")
local font = Crisp.newSdfFont(48, 4, "arial.fnt", "arial.png")

love.window.setFullscreen(true, "desktop")
local function checkInTable(val, table)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end
function love.load()
    friction_coeff = Slider:new(100, 100, 200, 20, 0, 1)


end
function love.update(dt)
    update_sliders()

    FRICTION_COEFFICIENT = friction_coeff:getValue()
     SAVED_ENERGY = TOTAL_ENERGY
    TOTAL_ENERGY = KINETIC_ENERGY + POTENTIAL_ENERGY
    ball.h = (love.graphics.getHeight() - FLOOR_HEIGHT) - (ball.y + BALL_RADIUS)
    -- KE = 1/2mv^2
    KINETIC_ENERGY = 0.5 * ball.mass * ((ball.vx/5)^2 + (ball.vy/5)^2)
    if KINETIC_ENERGY <= 10 then
        KINETIC_ENERGY = 0
    end
    -- DIRECTIONS OF VELOCITY
    if ball.vx > 0 then
        VELOCITY_DIR_X = ">"
    else
        VELOCITY_DIR_X = "<"
    end
    if ball.vy > 0 then
        VELOCITY_DIR_Y = ">"
    else
        VELOCITY_DIR_Y = "<"
    end
    -- PE = mgh
    POTENTIAL_ENERGY = ball.mass * GRAVITY * ball.h 
    -- Apply acceleration from keyboard input
    if love.keyboard.isDown("a") then
        ball.ax = -ACCELERATION
    elseif love.keyboard.isDown("d") then
        ball.ax = ACCELERATION
    else
        ball.ax = 0
    end
    
    -- Apply friction if the ball is grounded
    if ball.grounded then
        ball.vx = ball.vx * (1 - FRICTION_COEFFICIENT * dt)
        if not checkInTable(" SOUND ", SOURCES_OF_DISSIPATION) then 
        table.insert(SOURCES_OF_DISSIPATION, " SOUND ")
        end
    end
    
    -- Apply gravity to the ball's vertical velocity
    ball.vy = ball.vy + ball.ay * dt
    
    -- Update ball velocity based on acceleration
    ball.vx = ball.vx + ball.ax * dt
    
    -- Apply border limit on screen sides
    if ball.x - BALL_RADIUS <= SCREEN_BORDER then
        ball.vx = math.abs(ball.vx) -- Reverse x velocity
        ball.x = SCREEN_BORDER + BALL_RADIUS
        if not checkInTable(" ELASTIC ", SOURCES_OF_DISSIPATION) then 
            table.insert(SOURCES_OF_DISSIPATION, " ELASTIC ")
        end
    elseif ball.x + BALL_RADIUS >= love.graphics.getWidth() - SCREEN_BORDER then
        ball.vx = -math.abs(ball.vx) -- Reverse x velocity
        ball.x = love.graphics.getWidth() - SCREEN_BORDER - BALL_RADIUS
        if not checkInTable(" ELASTIC ", SOURCES_OF_DISSIPATION) then 
            table.insert(SOURCES_OF_DISSIPATION, " ELASTIC ")
        end
    end
    -- Update rolling time
    if ball.grounded then
        ROLLING_FACTOR = ROLLING_FACTOR + 1 * dt
    end
    if ROLLING_FACTOR >= 4 then
        if not checkInTable(" THERMAL ", SOURCES_OF_DISSIPATION) then 
            table.insert(SOURCES_OF_DISSIPATION, " THERMAL ")
        end
    end
    if ROLLING_FACTOR >= 2 then
        if not checkInTable(" FRICTION ", SOURCES_OF_DISSIPATION) then 
            table.insert(SOURCES_OF_DISSIPATION, " FRICTION ")
        end        
    end
    -- Update ball position based on velocity
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt
    
    -- Bounce the ball when it hits the floor
    if ball.y + BALL_RADIUS >= love.graphics.getHeight() - FLOOR_HEIGHT then
        ball.y = love.graphics.getHeight() - FLOOR_HEIGHT - BALL_RADIUS
        if love.keyboard.isDown("w") then
            ball.vy = JUMP_VELOCITY -- Apply jump velocity if "W" is pressed
        else
            ball.vy = -ball.vy * BOUNCE_FACTOR -- Reverse velocity and reduce it by the bounce factor
        end
        ball.grounded = true -- Set grounded flag to true
    else
        ball.grounded = false -- Set grounded flag to false if not on the ground
    end
    
    -- Ensure the ball stays above the floor
    if ball.y - BALL_RADIUS <= 0 then
        ball.y = BALL_RADIUS
        ball.vy = -ball.vy * BOUNCE_FACTOR -- Reverse velocity and reduce it by the bounce factor
    end

    if POTENTIAL_ENERGY <= 4 then
        POTENTIAL_ENERGY = 0
    end
    DISSIPATED_ENERGY = DISSIPATED_ENERGY + (math.abs( SAVED_ENERGY - TOTAL_ENERGY))/10^3

    DISSIPATION_VALUES = table.concat(SOURCES_OF_DISSIPATION)

    if love.keyboard.isDown("escape") then
        love.event.quit()
    elseif love.keyboard.isDown("r") then
        love.event.quit("restart")
    end
end

function love.draw()
    -- Draw the floor
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() - FLOOR_HEIGHT, love.graphics.getWidth(), FLOOR_HEIGHT)
    local size = 30
    font:setSize(size)

    -- Draw the ball
    love.graphics.setColor(1, 1, 1)
    font:print("Kinetic Energy : ".. Round(KINETIC_ENERGY, 2).. " J" ..
                        "\nPotential Energy : ".. Round(POTENTIAL_ENERGY, 2).." J" ..
                        "\nTotal Energy : ".. Round(TOTAL_ENERGY, 2).." J" ..
                        "\nDissipated Energy (" ..DISSIPATION_VALUES..") : ".. Round(DISSIPATED_ENERGY, 2).." J" ..
                        "\n -> OTHER FACTORS [ DISSIPATED ]")
    local ballVX =  math.abs(math.floor(ball.vx))
    local ballVY = math.abs(math.floor(ball.vy))
    if math.abs(ball.vy) <=4 then
        ballVY = 0
    end
    draw_sliders()

    love.graphics.setColor(1,1 - HEAT_FACTOR, 1 - HEAT_FACTOR)
    font:print("( x: "..ballVX.." "..VELOCITY_DIR_X..", y: "..ballVY.." "..VELOCITY_DIR_Y..") m/s", ball.x - 100, ball.y - 60)
    love.graphics.circle("fill", ball.x, ball.y, BALL_RADIUS)
end
function love.mousepressed(mx, my, button)
    mousepressed_sliders(mx, my, button)
end

function love.mousereleased(mx, my, button)
    mousereleased_sliders(mx, my, button)
end

function Round(num, dp)
    --[[
    round a number to so-many decimal of places, which can be negative, 
    e.g. -1 places rounds to 10's,  
    
    examples
        173.2562 rounded to 0 dps is 173.0
        173.2562 rounded to 2 dps is 173.26
        173.2562 rounded to -1 dps is 170.0
    ]]--
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end