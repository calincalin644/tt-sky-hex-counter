## How it works

This project displays a hexadecimal counter on the Tiny Tapeout demo board's
seven-segment display. With a 1 MHz input clock it advances once per second:

`0, 1, 2, 3, 4, 5, 6, 7, 8, 9, A, b, C, d, E, F`, then back to `0`.

A divider counts 1,000,000 rising clock edges for each increment of a four-bit
counter. A decoder converts the counter value to active-high segment outputs.
The lowercase b and d glyphs distinguish them from 8 and 0.

Outputs `uo[0]` through `uo[6]` drive segments A through G respectively.
Output `uo[7]` is the decimal point and is always off. All dedicated inputs are
unused. All bidirectional pins are configured as inputs and are unused.

The active-low reset is synchronous: on a rising clock edge with `rst_n=0`,
both the digit and divider reset to zero. When `ena=0`, both counters hold.
The first increment occurs 1,000,000 enabled clock edges after reset is released.

## How to test

1. Select this project on the Tiny Tapeout demo board.
2. Set the project clock to 1,000,000 Hz and start it.
3. Assert reset low for at least one clock cycle, then release it high.
4. Confirm the display starts at 0 and advances once per second through F.
5. Confirm F wraps to 0 and asserting reset returns the display to 0.

No DIP switch settings are required. Changing the project clock frequency changes
the count rate proportionally. Keep the clock running during reset.

The automated tests check all hexadecimal segment patterns, the million-cycle
interval, wraparound, enable/pause behavior, reset priority and divider reset,
and the unused bidirectional outputs. They use the real divider for both RTL
and gate-level simulation.

## External hardware

Only the Tiny Tapeout demo board's built-in seven-segment display is required.
