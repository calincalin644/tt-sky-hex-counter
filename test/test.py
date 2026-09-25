import cocotb
from cocotb.triggers import Timer

CLOCK_HZ = 1_000_000
SEGMENTS = (0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07,
            0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71)


async def cycles(count):
    # tb.v supplies a 1000 ns clock. Calls retain a safe sampling phase.
    await Timer(count * 1000, unit="ns")


def check(dut, digit):
    actual = int(dut.uo_out.value)
    assert actual == SEGMENTS[digit], (
        f"Expected digit {digit:X}: segments {SEGMENTS[digit]:02X}, got {actual:02X}"
    )
    assert int(dut.uio_oe.value) == 0, "Unused bidirectional pins must be inputs"
    assert int(dut.uio_out.value) == 0


@cocotb.test()
async def test_hex_counter(dut):
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    # Sample 100 ns after a falling edge, allowing gate-level settling.
    await Timer(10_100, unit="ns")
    check(dut, 0)
    dut.rst_n.value = 1

    for digit in range(16):
        await cycles(CLOCK_HZ - 1)
        check(dut, digit)  # Must not advance one cycle early.
        await cycles(1)
        check(dut, (digit + 1) % 16)
        dut._log.info("Verified %X -> %X", digit, (digit + 1) % 16)

    # Pause halfway through a second, including changes to unused inputs.
    await cycles(CLOCK_HZ // 2)
    dut.ena.value = 0
    dut.ui_in.value = 255
    dut.uio_in.value = 255
    await cycles(CLOCK_HZ + 3)
    check(dut, 0)
    dut.ena.value = 1
    await cycles(CLOCK_HZ // 2 - 1)
    check(dut, 0)
    await cycles(1)
    check(dut, 1)

    # Reset mid-period while disabled; verify digit and timer are both cleared.
    await cycles(CLOCK_HZ // 2)
    dut.ena.value = 0
    dut.rst_n.value = 0
    await cycles(2)
    check(dut, 0)
    dut.rst_n.value = 1
    dut.ena.value = 1
    await cycles(CLOCK_HZ - 1)
    check(dut, 0)
    await cycles(1)
    check(dut, 1)
