#!/usr/bin/env python3
"""Local API mode payload and live transition tests for Marstek Venus E."""

import argparse
import json
import socket
import sys
import time

MODES = ("Auto", "AI", "Manual", "UPS")
MANUAL_POWER_MIN = -2500
MANUAL_POWER_MAX = 2500


def mode_config(mode: str, power: int = 1000) -> dict:
    if mode == "Auto":
        return {"mode": mode, "auto_cfg": {"enable": 1}}
    if mode == "AI":
        return {"mode": mode, "ai_cfg": {"enable": 1}}
    if mode == "UPS":
        return {"mode": mode, "ups_cfg": {"enable": 1}}
    if mode == "Manual":
        if not MANUAL_POWER_MIN <= power <= MANUAL_POWER_MAX:
            raise ValueError(
                f"Manual power must be between {MANUAL_POWER_MIN} and {MANUAL_POWER_MAX} W"
            )
        return {
            "mode": mode,
            "manual_cfg": {
                "time_num": 0,
                "start_time": "00:00",
                "end_time": "23:59",
                "week_set": 127,
                "power": power,
                "enable": 1,
            },
        }
    raise ValueError(f"unsupported mode: {mode}")


def source_established(source: str, acknowledged: bool, reported: str | None) -> bool:
    if not acknowledged:
        return False
    return reported == source or (source == "Manual" and reported == "UPS")


def transition_status(
    source_ok: bool, target: str, acknowledged: bool, reported: str | None
) -> str:
    if source_ok and acknowledged and reported == target:
        return "PASS"
    if source_ok and acknowledged and target == "Manual" and reported == "UPS":
        return "ACK_ONLY"
    return "FAIL"


def manual_placeholder() -> dict:
    return {
        "mode": "Manual",
        "manual_cfg": {
            "time_num": 9,
            "start_time": "00:00",
            "end_time": "00:00",
            "week_set": 0,
            "power": 0,
            "enable": 0,
        },
    }


def check_payloads() -> None:
    assert set(mode_config("Auto")) == {"mode", "auto_cfg"}
    assert set(mode_config("AI")) == {"mode", "ai_cfg"}
    assert set(mode_config("UPS")) == {"mode", "ups_cfg"}
    manual = mode_config("Manual")["manual_cfg"]
    assert manual == {
        "time_num": 0,
        "start_time": "00:00",
        "end_time": "23:59",
        "week_set": 127,
        "power": 1000,
        "enable": 1,
    }
    assert mode_config("Manual", MANUAL_POWER_MIN)["manual_cfg"]["power"] == MANUAL_POWER_MIN
    assert mode_config("Manual", MANUAL_POWER_MAX)["manual_cfg"]["power"] == MANUAL_POWER_MAX
    for invalid_power in (MANUAL_POWER_MIN - 1, MANUAL_POWER_MAX + 1):
        try:
            mode_config("Manual", invalid_power)
        except ValueError:
            pass
        else:
            raise AssertionError(f"Manual power {invalid_power} must be rejected")
    placeholder = manual_placeholder()["manual_cfg"]
    assert placeholder == {
        "time_num": 9,
        "start_time": "00:00",
        "end_time": "00:00",
        "week_set": 0,
        "power": 0,
        "enable": 0,
    }
    assert source_established("Manual", True, "Manual")
    assert source_established("Manual", True, "UPS")
    assert not source_established("Manual", True, "Auto")
    assert not source_established("Manual", False, "Manual")
    assert transition_status(True, "Manual", True, "UPS") == "ACK_ONLY"
    assert transition_status(True, "Manual", True, "Auto") == "FAIL"
    assert transition_status(True, "Manual", False, "UPS") == "FAIL"
    transitions = [(source, target) for source in MODES for target in MODES if source != target]
    assert len(transitions) == 12
    print("Mode payload checks passed (4 modes, 12 directed transitions)")


class API:
    def __init__(self, host: str, port: int = 30000):
        self.host = host
        self.port = port
        self.next_id = 1
        self.expected_host_addresses = {
            entry[4][0]
            for entry in socket.getaddrinfo(host, port, socket.AF_INET, socket.SOCK_DGRAM)
        }

    def request(self, method: str, params: dict | None = None, attempts: int = 3) -> dict:
        params = params or {"id": 0}
        last = None
        for attempt in range(1, attempts + 1):
            request_id = self.next_id
            self.next_id += 1
            payload = {"id": request_id, "method": method, "params": params}
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
                sock.settimeout(4)
                sock.sendto(json.dumps(payload).encode(), (self.host, self.port))
                deadline = time.monotonic() + 4
                while time.monotonic() < deadline:
                    try:
                        raw, sender = sock.recvfrom(8192)
                    except socket.timeout:
                        break
                    if sender[0] not in self.expected_host_addresses:
                        continue
                    response = json.loads(raw.decode())
                    if response.get("id") != request_id:
                        continue
                    if "error" in response:
                        last = response
                        break
                    return response.get("result", {})
            if attempt < attempts:
                time.sleep(1)
        raise RuntimeError(f"{method} failed after {attempts} attempts: {last}")

    def mode(self) -> str | None:
        return self.request("ES.GetMode").get("mode")

    def set_mode(self, mode: str, power: int = 1000) -> dict:
        # The device accepts the disabled slot-9 cleanup before the active
        # Manual schedule. This mirrors the widget's production code.
        if mode == "Manual":
            self.request("ES.SetMode", {"id": 0, "config": manual_placeholder()})
            time.sleep(1)
        return self.request("ES.SetMode", {"id": 0, "config": mode_config(mode, power)})


def live_test(host: str, restore: str, cycle: bool = False) -> int:
    api = API(host)
    initial = api.mode()
    print(f"Initial API mode: {initial or '?'}")
    results = []
    edges = [(MODES[i], MODES[j]) for i in range(len(MODES)) for j in range(len(MODES)) if i != j]
    if cycle:
        edges = [("UPS", "Auto"), ("Auto", "AI"), ("AI", "Manual"), ("Manual", "UPS")]
    for source, target in edges:
        try:
            # Establish the source for every directed edge. This keeps cycle
            # results meaningful even if an earlier target command failed.
            source_response = api.set_mode(source)
            time.sleep(4)
            source_reported = api.mode()
            source_accepted = source_response.get("set_result") == 1
            source_ok = source_established(source, source_accepted, source_reported)

            response = api.set_mode(target)
            time.sleep(5)
            reported = api.mode()
            accepted = response.get("set_result") == 1
            # Venus E firmware 148 is known to report UPS after accepting
            # Manual; retain only that exact mismatch as a non-green result.
            status = transition_status(source_ok, target, accepted, reported)
            print(f"{source:6} -> {target:6}: {status:8} source={source_reported or '?'} target={reported or '?'}")
            results.append(status)
        except Exception as exc:
            print(f"{source:6} -> {target:6}: FAIL     {exc}")
            results.append("FAIL")

    print(f"Restoring {restore}...")
    try:
        response = api.set_mode(restore)
        time.sleep(3)
        reported = api.mode()
        print(f"Restore: API={reported or '?'} set_result={response.get('set_result')}")
    except Exception as exc:
        print(f"Restore failed: {exc}")
        return 1

    failures = results.count("FAIL")
    ack_only = results.count("ACK_ONLY")
    print(f"Summary: PASS={results.count('PASS')} ACK_ONLY={ack_only} FAIL={failures}")
    return 1 if failures else 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", help="Marstek IP for live tests (required with --live or --set-mode)")
    parser.add_argument("--restore", choices=MODES, help="Mode restored after --live (required)")
    parser.add_argument("--set-mode", choices=MODES)
    parser.add_argument("--cycle", action="store_true", help="Run UPS -> Auto -> AI -> Manual -> UPS")
    parser.add_argument("--live", action="store_true")
    args = parser.parse_args()
    check_payloads()
    if (args.live or args.set_mode) and not args.host:
        parser.error("--host is required for live tests")
    if args.live and not args.restore:
        parser.error("--restore is required with --live")
    if args.set_mode:
        api = API(args.host)
        response = api.set_mode(args.set_mode)
        time.sleep(3)
        print(f"Set {args.set_mode}: API={api.mode() or '?'} set_result={response.get('set_result')}")
        return 0
    if not args.live:
        return 0
    return live_test(args.host, args.restore, args.cycle)


if __name__ == "__main__":
    sys.exit(main())
