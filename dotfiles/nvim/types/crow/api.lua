---@meta
-- Editor-only API descriptions; never require or upload this file.
-- Sources: https://monome.org/docs/crow/reference/
-- https://github.com/monome/crow/tree/main/lua

---@alias CrowShape 'linear'|'sine'|'log'|'logarithmic'|'expo'|'exponential'|'now'|'wait'|'over'|'under'|'rebound'
---@alias CrowInputMode 'none'|'stream'|'change'|'window'|'scale'|'volume'|'peak'|'freq'|'clock'
---@alias CrowAction table|string
---@alias CrowValue number|CrowDynamic

---@class CrowInputModeCall
---@overload fun(mode: 'none')
---@overload fun(mode: 'stream'|'volume'|'freq', time?: number)
---@overload fun(mode: 'change', threshold?: number, hysteresis?: number, direction?: 'rising'|'falling'|'both')
---@overload fun(mode: 'window', windows: number[], hysteresis?: number)
---@overload fun(mode: 'scale', notes: number[], temperament?: number|'ji', scaling?: number)
---@overload fun(mode: 'peak', threshold?: number, hysteresis?: number)
---@overload fun(mode: 'clock', division?: number)

---@class CrowInput
---@overload fun(settings: table)
---@field volts number Current input voltage (read-only).
---@field mode CrowInputModeCall|CrowInputMode Configure detection. Times are seconds; freq is available on input 1 only.
---@field query fun() Report the current voltage to the USB host.
---@field stream fun(volts: number) Voltage stream callback.
---@field change fun(state: boolean) Threshold crossing callback; true is high.
---@field window fun(index: integer, rising: boolean) Voltage window transition callback.
---@field scale fun(note: {index: integer, octave: integer, note: number, volts: number}) Quantizer callback.
---@field volume fun(level: number) RMS amplitude callback.
---@field peak fun() Transient callback.
---@field freq fun(hz: number) Frequency callback (input 1).
---@field time number Reporting interval in seconds.
---@field threshold number Detection threshold in volts.
---@field hysteresis number Noise margin in volts.
---@field direction 'rising'|'falling'|'both'
---@field windows number[] Window boundaries in volts.
---@field notes number[] Quantizer notes or ratios.
---@field temp number|'ji' Temperament; normally 12.
---@field scaling number Volts per octave.
---@field div number Clock input division in beats.

---Crow's two CV inputs: `input[1]` and `input[2]`.
---@type CrowInput[]
input = {}

---@class CrowOutputScale
---@overload fun(notes: number[]|'none', temperament?: number|'ji', scaling?: number)

---@class CrowOutput
---@overload fun(action_or_gate?: CrowAction|boolean)
---@field volts number Set the target voltage, or read the instantaneous voltage.
---@field slew number Ramp duration in seconds; initially zero.
---@field shape CrowShape Curve used when changing volts.
---@field action CrowAction Assign an ASL envelope or sequence; call the output to start it.
---@field scale CrowOutputScale|number[] Quantize output; use 'none' to disable, or 'ji' temperament for ratios.
---@field dyn table<string, number> Update named dynamic ASL values while the action runs.
---@field done fun() Called when an action finishes.
---@field clock fun(self: CrowOutput, division?: number|'none') Emit beat-synchronized pulses; use colon syntax.
---@field clock_div number Change the clock division without restarting its phase.
---@field query fun() Report output voltage to the USB host.
---@field receive fun(volts: number) Output query callback.

---Crow's four CV outputs. `output[1](true)` gates an envelope on; false releases it.
---@type CrowOutput[]
output = {}

---Build an oscillating ASL action. Defaults: 1 second, 5 volts, sine.
---@param time? CrowValue Period in seconds.
---@param level? CrowValue Peak voltage.
---@param shape? CrowShape
---@return CrowAction
function lfo(time, level, shape) end

---Build a pulse action. Defaults: 0.01 seconds, 5 volts, positive polarity.
---@param time? CrowValue
---@param level? CrowValue
---@param polarity? number
---@return CrowAction
function pulse(time, level, polarity) end

---Build a skewed triangular oscillator.
---@param time? CrowValue Period in seconds (default 1).
---@param skew? CrowValue Rising fraction (default 0.25).
---@param level? CrowValue Peak voltage (default 5).
---@return CrowAction
function ramp(time, skew, level) end

---Build a retriggerable attack-release envelope.
---@param attack? CrowValue Seconds (default 0.05).
---@param release? CrowValue Seconds (default 0.5).
---@param level? CrowValue Volts (default 7).
---@param shape? CrowShape Default log.
---@return CrowAction
function ar(attack, release, level, shape) end

---Build an ADSR action. Call the output with true to attack, false to release.
---@param attack? CrowValue Seconds (default 0.05).
---@param decay? CrowValue Seconds (default 0.3).
---@param sustain? CrowValue Volts (default 2).
---@param release? CrowValue Seconds (default 2).
---@param shape? CrowShape Default linear.
---@return CrowAction
function adsr(attack, decay, sustain, release, shape) end

---Build an audio-rate oscillator action.
---@param freq? CrowValue Frequency in hertz (default 1).
---@param level? CrowValue Peak voltage (default 5).
---@param shape? CrowShape Default sine.
---@return CrowAction
function oscillate(freq, level, shape) end

---ASL segment: travel to a voltage over a duration.
---@param destination CrowValue Volts.
---@param time? CrowValue Seconds.
---@param shape? CrowShape
---@return CrowAction
function to(destination, time, shape) end

---Repeat an ASL sequence indefinitely.
---@param actions CrowAction[]
---@return CrowAction
function loop(actions) end

---Hold at the sequence end until the output receives a release directive.
---@param actions CrowAction[]
---@return CrowAction
function held(actions) end

---Ignore incoming directives until this sequence finishes.
---@param actions CrowAction[]
---@return CrowAction
function lock(actions) end

---Repeat an ASL sequence a fixed number of times.
---@param count CrowValue
---@param actions CrowAction[]
---@return CrowAction
function times(count, actions) end

---@class CrowDynamic
---@operator add(number): CrowDynamic
---@operator sub(number): CrowDynamic
---@operator mul(number): CrowDynamic
---@operator div(number): CrowDynamic
---@field step fun(self: CrowDynamic, increment: number): CrowDynamic Add on each access.
---@field mul fun(self: CrowDynamic, factor: number): CrowDynamic Multiply on each access.
---@field wrap fun(self: CrowDynamic, minimum: number, maximum: number): CrowDynamic Wrap to a range.

---Create a named ASL value; change it later through `output[n].dyn.name`.
---@param values table<string, number>
---@return CrowDynamic
function dyn(values) end

---@class CrowASL
---@field _if fun(predicate: any, actions: CrowAction[]): CrowAction
---@field _while fun(predicate: any, actions: CrowAction[]): CrowAction
---@type CrowASL
asl = {}

---@class CrowSequins
---@overload fun(): any
---@operator add(any): CrowSequins
---@operator sub(any): CrowSequins
---@operator mul(any): CrowSequins
---@operator div(any): CrowSequins
---@field [integer] any
---@field ix integer Current sequence position.
---@field step fun(self: CrowSequins, increment: number): CrowSequins Change index step.
---@field select fun(self: CrowSequins, index: integer): CrowSequins Choose the next index.
---@field settable fun(self: CrowSequins, values: table): CrowSequins Replace data, preserving position.
---@field every fun(self: CrowSequins, n: integer): CrowSequins Yield on every nth call.
---@field times fun(self: CrowSequins, n: integer): CrowSequins Yield only n times.
---@field count fun(self: CrowSequins, n: integer): CrowSequins Hold focus for n values.
---@field all fun(self: CrowSequins): CrowSequins Yield the entire nested sequence.
---@field reset fun(self: CrowSequins): CrowSequins Reset position and flow state.
---@field map fun(self: CrowSequins, transform?: function): CrowSequins Set or clear a transform.
---@field copy fun(self: CrowSequins): CrowSequins Copy data and modifiers.
---@field bake fun(self: CrowSequins, n: integer): CrowSequins Sample n future values.
---@field peek fun(self: CrowSequins): any Inspect without advancing.

---Create a cyclic sequence; calling it returns the next value. Supports nesting.
---@param values table|string
---@return CrowSequins
function sequins(values) end

---@class CrowMetro
---@field time number Interval in seconds.
---@field count integer Number of events; -1 repeats indefinitely.
---@field event fun(stage: integer) Timer callback.
---@field start fun(self: CrowMetro, time?: number, count?: integer, stage?: integer)
---@field stop fun(self: CrowMetro)

---@class CrowMetros
---@field [integer] CrowMetro Eight timers, indexed 1 through 8.
---@field init fun(settings: {event: function, time?: number, count?: integer}): CrowMetro Allocate a timer; use this with delay.
---@field free fun(id: integer) Release a timer.
---@field free_all fun() Release all timers.
---@type CrowMetros
metro = {}

---@class CrowClock
---@field tempo number Beats per minute. Read-only when driven by a clock input.
---@field transport {start: fun(), stop: fun()} Transport callbacks.
---@field run fun(action: function, ...: any): integer Start a coroutine; returns its cancellation ID.
---@field cancel fun(id: integer) Cancel a running coroutine.
---@field sleep fun(seconds: number) Pause inside a clock.run coroutine.
---@field sync fun(beats: number, offset?: number) Resume at the next beat division; requires clock.run.
---@field cleanup fun() Cancel all clock routines.
---@field get_beats fun(): number Elapsed beats (call as a function).
---@field get_beat_sec fun(beats?: number): number Beat duration in seconds (call as a function).
---@field start fun(beat?: number) Start transport, optionally from a chosen beat.
---@field stop fun() Stop transport.
---@type CrowClock
clock = {}

---Schedule a function after a delay. When mixing with metro, use metro.init.
---@param action function
---@param time number Seconds.
---@param repeats? integer
function delay(action, time, repeats) end

---@class CrowTimeline
---@field play fun(self: CrowTimeline) Start or restart playback.
---@field stop fun(self: CrowTimeline) Stop playback.
---@field unless fun(self: CrowTimeline, predicate: fun(): boolean): CrowTimeline Conditional loop termination.
---@field times fun(self: CrowTimeline, count: integer): CrowTimeline Limit repetitions.
---@field loop fun(self: CrowTimeline, events: table): CrowTimeline Alternating durations and actions, in beats.
---@field score fun(self: CrowTimeline, events: table): CrowTimeline Beat timestamps and actions.
---@field real fun(self: CrowTimeline, events: table): CrowTimeline Timestamps in seconds.

---@class CrowTimelines
---@field loop fun(events: table): CrowTimeline Start a repeating beat sequence.
---@field score fun(events: table): CrowTimeline Start a score using absolute beats.
---@field real fun(events: table): CrowTimeline Start a score using seconds.
---@field queue fun(): CrowTimeline Construct a stopped timeline for later playback.
---@field launch fun(beats: number): CrowTimeline Set launch quantization for the next timeline.
---@field launch_default number Default launch quantization, in beats.
---@field cleanup fun() Stop timelines and clock routines.
---@type CrowTimelines
timeline = {}

---Replace named sequins or timelines while preserving playback position.
---@type table<string, CrowSequins|CrowTimeline>
hotswap = {}

---@class CrowIIMetadata
---@field name string Requested parameter.
---@field arg any First query argument.
---@field device integer Device index.

---@class CrowIIDevice
---@field [integer] CrowIIDevice Select a particular device on the bus.
---@field [string] any Device-specific functions vary by firmware; use device.help().
---@field help fun() Print device commands in druid.
---@field get fun(parameter: string, ...: any) Query asynchronously; response goes to event.
---@field event fun(event: CrowIIMetadata, value: any) Query response callback.

---@class CrowJustFriends: CrowIIDevice
---@field play_note fun(pitch_or_divs: number, level_or_repeats: number) Allocate a synthesis note (pitch in volts) or Geode pattern.
---@field play_voice fun(channel: integer, pitch_or_divs: number, level_or_repeats: number) Address one voice.
---@field trigger fun(channel: integer, state: integer) Set a trigger state.
---@field mode fun(mode: integer) Select synthesis/Geode with nonzero mode.

---@class CrowII
---@field [string] CrowIIDevice|any
---@field jf CrowJustFriends Just Friends.
---@field crow CrowIIDevice Crow peers.
---@field txi CrowIIDevice Telex inputs.
---@field txo CrowIIDevice Telex outputs.
---@field er301 CrowIIDevice ER-301.
---@field address integer This crow's bus index, 1 through 4.
---@field help fun() List available ii devices in druid.
---@field raw fun(address: integer, bytes: string, response_length?: integer) Send a raw I2C request.
---@field event_raw fun(address: integer, command: integer, data: any): boolean Return true when handled.
---@field fastmode fun(enabled: boolean) Change bus speed.
---@field pullup fun(enabled: boolean) Enable or disable bus pullups.
---@type CrowII
ii = {}

---@class CrowPublicParameter
---@field range fun(self: CrowPublicParameter, minimum: number|number[], maximum?: number): CrowPublicParameter Set bounds.
---@field type fun(self: CrowPublicParameter, hint: string): CrowPublicParameter Set host UI metadata.
---@field options fun(self: CrowPublicParameter, choices: string[]): CrowPublicParameter Restrict allowed strings.
---@field action fun(self: CrowPublicParameter, callback: function): CrowPublicParameter React to host edits.

---@class CrowPublic
---@overload fun(values: table<string, any>): CrowPublicParameter
---@field [string] any Host-synchronized variables.
---@field discover fun() List declared public variables.
---@field update fun(name: string, value: any, subkey?: any) Update and invoke its action.
---@field view {all: fun(enabled?: boolean), input: table<integer, fun(enabled?: boolean)>, output: table<integer, fun(enabled?: boolean)>}
---@type CrowPublic
public = {}

---@class CrowCalibration
---@field save fun() Persist calibration to flash.
---@field source fun(channel: integer) Route the calibration multiplexer.
---@field input table<integer, {offset: number, scale: number}>
---@field output table<integer, {offset: number, scale: number}>
---@type CrowCalibration
cal = {}

---@class CrowSystem
---@field reset fun() Reset I/O and timers without launching the saved script.
---@type CrowSystem
crow = {}

---Script initialization hook, invoked when a script starts.
function init() end

---Format an event for the USB host.
---@param event string
---@param ... any
function tell(event, ...) end

---Serialize values as Lua text.
---@param ... any
---@return string
function quote(...) end

---Three integers identifying this crow's hardware.
---@return integer, integer, integer
function unique_id() end

---Milliseconds since startup.
---@return number
function time() end

---Print a DSP workload measurement in druid.
function cputime() end

---Convert a just-intonation ratio to volts per octave.
---@param fraction number|number[]
---@param offset? number Transposition ratio.
---@return number|number[]
function justvolts(fraction, offset) end

---Convert a ratio to semitone units.
---@param fraction number|number[]
---@param offset? number Transposition ratio.
---@return number|number[]
function just12(fraction, offset) end

---Convert hertz to volts; the reference frequency corresponds to zero volts.
---@param frequency number
---@param reference? number Defaults to middle C.
---@return number
function hztovolts(frequency, reference) end

---Seed crow's repeatable pseudo-random generator (math.random uses hardware randomness).
---@param seed number
function math.srandomseed(seed) end

---Sample crow's seeded generator: no arguments gives a fraction, bounds give integers.
---@param minimum? integer
---@param maximum? integer
---@return number
function math.srandom(minimum, maximum) end
