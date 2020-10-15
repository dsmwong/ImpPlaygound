// Reading a Sensor Agent Code
// ---------------------------------------------------

// CLOUD SERVICE LIBRARY
// ---------------------------------------------------
// Libraries must be included before all other code

// Initial State Library
#require "InitialState.class.nut:1.0.0"

#require "JSONEncoder.class.nut:2.0.0"

@include "include.nut"

// SETUP
// ---------------------------------------------------
// Set up an account with Initial State. Log in and 
// navigate to "my account" page.

// On "my account" page find/create a "Streaming Access Key"
// Paste it into the constant below
const STREAMING_ACCESS_KEY = "@{STREAM_ACCESS_KEY}"; 

// Initialize Initial State
local iState = InitialState(STREAMING_ACCESS_KEY);

// The library will create a bucket using the agent ID 
// Let's log the agent ID here
local agentID = split(http.agenturl(), "/").top();
server.log("Agent ID: " + agentID);


// RUNTIME
// ---------------------------------------------------
server.log("Agent running...");
server.log(MYCONST);

// Open listener for "reading" messages from the device
device.on("reading", function(reading) {
    // Log the reading from the device. The reading is a 
    // table, so use JSON encodeing method convert to a string
    server.log(http.jsonencode(reading));
    // Initial State requires the data in a specific structre
    // Build an array with the data from our reading.
    local events = [];
    events.push({"key" : "temperature", "value" : reading.temperature, "epoch" : time()});
    events.push({"key" : "humidity", "value" : reading.humidity, "epoch" : time()});

    // Send reading to Initial State
    //iState.sendEvents(events, function(err, resp) {
    //    if (err != null) {
    //        // We had trouble sending to Initial State, log the error
    //        server.error("Error sending to Initial State: " + err);
    //    } else {
    //        // A successful send. The response is an empty string, so
    //        // just log a generic send message
    //        server.log("Reading sent to Initial State.");
    //    }
    //})
    
    local eventsStr = JSONEncoder.encode(events);
    server.log("Pretending to send events. " + eventsStr)
})

device.on("dimmed_light", function(message) {
    server.log(format("It's pretty dark, turn the light on. Currently %s", http.jsonencode(message)));
})
