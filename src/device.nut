// Reading a Sensor Device Code
// ---------------------------------------------------

// SENSOR LIBRARY
// ---------------------------------------------------
// Libraries must be included before all other code

// Temperature Humidity sensor Library
#require "HTS221.device.lib.nut:2.0.1"
#require "WS2812.class.nut:3.0.0"


// SETUP
// ---------------------------------------------------
// The HTS221 library uses the sensor's i2c interface
// To initialize the library we need to configure the
// i2c and pass in the 12c address for our hardware.

// The i2c address for the Explorer Kits and the
// Battery Powered Sensor Node are all 0xBE.
const I2C_ADDR = 0xBE;

// Set up global variables
spi <- null;
led <- null;
state <- false;

// Find the i2c for your hardware from the list below.
// Paste the hardware.i2c for your hardware into the
// i2c variable on line 32.

// imp006 Breakout Board Kit                   i2c = hardware.i2cLM
// impExplorer Dev Kit 001                     i2c = hardware.i2c89
// impExplorer Dev Kit 004m                    i2c = hardware.i2cNM
// impAccelerator Battery Powered Sensor Node  i2c = hardware.i2cAB
// impC001 Cellular Breakout Board Kit         i2c = hardware.i2cKL

// Configure i2c
// Paste your i2c hardware in the variable below
local i2c = hardware.i2c89;
i2c.configure(CLOCK_SPEED_400_KHZ);

// Initialize the temperature/humidity sensor
local tempHumid = HTS221(i2c, I2C_ADDR);

// Before we can take a reading we need to configure
// the sensor. Note: These steps vary for different
// sensors. This sensor we just need to set the mode.

// We are going to set up the sensor to take a single
// reading when we call the read method.
tempHumid.setMode(HTS221_MODE.ONE_SHOT);

local COLOR_CANDLE = [255,147,41];
local COLOR_OLIVE = [128,128,0];
local COLOR_VIOLET = [148,0,211];
local COLOR_RED = [255,0,0];
local COLOR_ORANGE = [255,100,0];

// APPLICATION FUNCTION(S)
// ---------------------------------------------------
// The sensor is now configured to taking readings.
// Lets set up a loop to take readings and send the
// result to the agent.

// Define the loop flash function
function flash() {
    state = !state;
    local color = state ? COLOR_CANDLE : [0,0,0];
    // intensity factor
    const f = 8
    local colorf = [color[0]/f, color[1]/f, color[2]/f];
    led.set(0, colorf).draw();
    
    imp.wakeup(1.0, flash); 
}

function loop() {
    // Take a reading
    local result = tempHumid.read();

    // Check the result
    if ("error" in result) {
        // We had an issue taking the reading, lets log it
        server.error(result.error);
    } else {
        // Let's log the reading
        server.log(format("Current Humidity: %0.2f %s, Current Temperature: %0.2f °C", result.humidity, "%", result.temperature));
        // Send the reading to the agent
        agent.send("reading", result);
    }
    
    local currentLightLevel = hardware.lightlevel();
    server.log("Current light level is: " + currentLightLevel);
    
    if( currentLightLevel < 20000 ) {
        agent.send("dimmed_light", currentLightLevel);
    }
    

    // Schedule next reading in 10sec
    // Change the first parameter to imp.wakeup to
    // adjust the loop time
    imp.wakeup(10, loop);
}

// RUNTIME
// ---------------------------------------------------
server.log("Device running...");

spi = hardware.spi257;
spi.configure(MSB_FIRST, 7500);
hardware.pin1.configure(DIGITAL_OUT, 1);

// Set up the RGB LED
led = WS2812(spi, 1);

// Start the readings loop
loop();
flash();