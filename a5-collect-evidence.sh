#!/usr/bin/env bash
#
# Assignment A5 evidence collector.
#
# Run this ON THE GATEWAY VM after completing the indicated question.
# It records structured, machine-parseable evidence into the fixed
# submission path for that question:
#
#   /home/tsam/assignment5/qN/evidence.txt
#
# Usage:
#   ./a5-collect-evidence.sh Q2 <client-internal-ip>
#   ./a5-collect-evidence.sh Q3 <client-internal-ip>
#   ./a5-collect-evidence.sh Q4 <client-internal-ip>
#   ./a5-collect-evidence.sh Q5 <client-internal-ip>
#   ./a5-collect-evidence.sh Q6 <client-internal-ip>
#   ./a5-collect-evidence.sh Q7 <client-internal-ip>
#
# <client-internal-ip> is the client's current address on the internal
# network (10.123.123.0/24). Before Q5, this is the address you assigned
# manually (normally 10.123.123.2). From Q5 onward, it is whatever
# address the client received via DHCP -- check with `ip -4 addr` on the
# client if you are not sure.
#
# Q1 does not use this script: it is answered entirely by hand in
# q1/answers.md (no evidence file).
#
# Q7 (the persistence bonus) also uses this script, but must be run only
# AFTER rebooting both the gateway and the client VM -- it collects
# post-reboot state, which is the whole point of that question. Running
# Q7 before rebooting, or re-running an earlier question (Q2-Q6) after
# rebooting, will overwrite that question's evidence file with
# misleading state, so only run each question's collection step once,
# at the point described in the assignment text.
#
# This script only reads state and runs small, harmless network probes.
# It does not change any configuration on either machine.
#
# PROGRESS OUTPUT: this script can take a while to run (Q6 in particular
# makes ~10 SSH round trips to the client, some of which deliberately
# wait out a multi-second timeout to confirm a port is blocked). It
# prints a line to stderr before each individual step so it's clear
# it's still working and not hung. Only the final evidence file itself
# is written to stdout/the qN/evidence.txt file; the progress lines are
# not part of the recorded evidence.

set -u
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The script lives directly inside assignment5/ (i.e. at
# assignment5/a5-collect-evidence.sh), so SCRIPT_DIR already IS the
# submission root. It must NOT go up a further level (a previous version
# of this script incorrectly did "$SCRIPT_DIR/.."), or evidence output
# ends up next to assignment5/ instead of inside it, e.g.
# /home/tsam/qN/evidence.txt instead of /home/tsam/assignment5/qN/evidence.txt.
SUBMISSION_DIR="$SCRIPT_DIR"

QUESTION="${1:-}"
CLIENT_IP="${2:-}"

usage() {
    echo "Usage: $0 Q2|Q3|Q4|Q5|Q6|Q7 <client-internal-ip>" >&2
    echo "  <client-internal-ip> is the client's current address on 10.123.123.0/24" >&2
    echo "  Run Q7 only AFTER rebooting both VMs (bonus persistence question)." >&2
    exit 2
}

if [[ ! "$QUESTION" =~ ^Q[2-7]$ ]]; then
    usage
fi

if [[ -z "$CLIENT_IP" ]]; then
    usage
fi

CLIENT_USER="tsam"
CLIENT_MGMT_IP="192.168.56.21"
SSH_TIMEOUT=5
PROBE_TIMEOUT=5
BLOCKED_TEST_PORT=5000

OUTPUT_FILE="${SUBMISSION_DIR}/${QUESTION,,}/evidence.txt"
TEMP_FILE="${OUTPUT_FILE}.tmp"

mkdir -p "$(dirname "$OUTPUT_FILE")"

cleanup() {
    rm -f "$TEMP_FILE"
}
trap cleanup EXIT

: > "$TEMP_FILE"

timestamp() {
    date -u '+%Y-%m-%dT%H:%M:%SZ'
}

# Prints a progress line to stderr, e.g. "==> [Q6] ruleset_dump ...".
# Always on stderr so it never ends up inside qN/evidence.txt (which is
# built purely from stdout redirects/explicit appends below).
progress() {
    echo "==> [${QUESTION}] $1 ..." >&2
}

# ---------------------------------------------------------------------
# Low-level evidence block helpers
# ---------------------------------------------------------------------

write_header() {
    local host="$1" role="$2" label="$3" command_text="$4" remote_host="${5:-}"
    {
        echo "=== A5-EVIDENCE-BEGIN ==="
        echo "QUESTION: ${QUESTION}"
        echo "HOST: ${host}"
        echo "ROLE: ${role}"
        echo "LABEL: ${label}"
        echo "COMMAND: ${command_text}"
        if [[ -n "$remote_host" ]]; then
            echo "REMOTE_HOST: ${remote_host}"
        fi
        echo "START_TIME_UTC: $(timestamp)"
        echo "OUTPUT:"
    } >> "$TEMP_FILE"
}

write_footer() {
    local exit_code="$1"
    {
        echo "EXIT_CODE: ${exit_code}"
        echo "END_TIME_UTC: $(timestamp)"
        echo "=== A5-EVIDENCE-END ==="
        echo
    } >> "$TEMP_FILE"
}

# Run a command locally on the gateway and record its output.
run_local() {
    local label="$1"
    shift
    local command_text="$*"
    progress "$label (local)"
    write_header "gateway" "gateway" "$label" "$command_text"
    "$@" >> "$TEMP_FILE" 2>&1
    write_footer "$?"
}

# Run a command on the client over SSH (using the gateway's key, which is
# already authorized on the client for the tsam user) and record output.
# Tries the internal IP first, falls back to the management IP so that a
# (correctly or incorrectly) restrictive Q6 firewall on the internal side
# does not prevent evidence collection entirely. Returns which target
# actually worked via the global LAST_SSH_TARGET, so callers can record
# it as REMOTE_HOST.
LAST_SSH_TARGET=""
ssh_client() {
    local target ssh_rc
    for target in "$CLIENT_IP" "$CLIENT_MGMT_IP"; do
        [[ -n "$target" ]] || continue
        ssh \
            -o BatchMode=yes \
            -o ConnectTimeout="$SSH_TIMEOUT" \
            -o ConnectionAttempts=1 \
            -o StrictHostKeyChecking=accept-new \
            "${CLIENT_USER}@${target}" \
            "$@"
        ssh_rc=$?
        if [[ $ssh_rc -ne 255 ]]; then
            # 255 = ssh itself could not connect; anything else means we
            # reached the client and got a real exit code back.
            LAST_SSH_TARGET="$target"
            return $ssh_rc
        fi
    done
    LAST_SSH_TARGET=""
    return 255
}

run_remote_client() {
    local label="$1"
    shift
    local command_text="$*"
    progress "$label (remote, via ssh)"
    local output
    output="$(ssh_client "$@" 2>&1)"
    local rc=$?
    write_header "client" "client" "$label" "$command_text" "$LAST_SSH_TARGET"
    printf '%s\n' "$output" >> "$TEMP_FILE"
    write_footer "$rc"
}

# Run a command on the client that PROBES SOMETHING ELSE (e.g. the client
# pinging the gateway, or the client connecting to an Internet host). The
# orchestration SSH hop to the client is separate from the thing being
# tested, so we record the probe's own exit code, not ssh's.
run_client_probe() {
    local label="$1" probe_command="$2"
    progress "$label (probe, may wait for a timeout)"
    local output
    output="$(ssh_client "$probe_command" 2>&1)"
    local rc=$?
    write_header "client" "client" "$label" "$probe_command" "$LAST_SSH_TARGET"
    printf '%s\n' "$output" >> "$TEMP_FILE"
    if [[ $rc -eq 255 ]]; then
        echo "COLLECTOR_NOTE: SSH orchestration to client failed on both addresses; this is NOT the probe result." >> "$TEMP_FILE"
    fi
    write_footer "$rc"
}

file_header() {
    {
        echo "A5-EVIDENCE-FILE-VERSION: 3"
        echo "QUESTION: ${QUESTION}"
        echo "COLLECTOR: a5-collect-evidence.sh"
        echo "COLLECTOR_HOST: gateway"
        echo "CLIENT_ADDRESS_USED: ${CLIENT_IP}"
        echo "COLLECTION_START_UTC: $(timestamp)"
        echo
    } >> "$TEMP_FILE"
}

file_footer() {
    echo "COLLECTION_END_UTC: $(timestamp)" >> "$TEMP_FILE"
}

# ---------------------------------------------------------------------
# Per-question collection
# ---------------------------------------------------------------------

collect_q2() {
    # Interface / address state on both machines.
    run_local "links" ip -br link
    run_local "addresses_ipv4" ip -br -4 addr
    run_remote_client "links" ip -br link
    run_remote_client "addresses_ipv4" ip -br -4 addr

    # Bidirectional connectivity on the internal network.
    run_local "ping_to_client" ping -c 2 -W 2 "$CLIENT_IP"
    run_client_probe "ping_to_gateway" "ping -c 2 -W 2 10.123.123.1"

    # Client Internet reachability is expected to FAIL at this stage
    # (no default route yet); a non-zero exit code here is normal and is
    # interpreted accordingly by the grader.
    run_client_probe "internet_ping_attempt" "ping -c 2 -W 2 8.8.8.8"
}

collect_q3() {
    run_remote_client "routes_ipv4" "ip -4 route"
    run_local "sysctl_forwarding" sysctl net.ipv4.ip_forward

    # Expected to succeed now that forwarding + NAT are configured.
    run_client_probe "internet_ping_attempt" "ping -c 3 -W 2 8.8.8.8"
    # Expected to still fail: no DNS server configured on the client yet.
    run_client_probe "dns_attempt" "nslookup google.com"
}

collect_q4() {
    # Interface names + MAC addresses, used only to cross-check the
    # student's manual MAC/interface table in q4/answers.md.
    run_local "links" ip -br link
    run_remote_client "links" ip -br link
}

collect_q5() {
    run_remote_client "network_interfaces_file" "cat /etc/network/interfaces"
    run_remote_client "addresses_ipv4" "ip -4 addr show dev eth0"
    run_remote_client "routes_ipv4" "ip -4 route"
    run_remote_client "resolv_conf" "cat /etc/resolv.conf"
    run_client_probe "dns_attempt" "nslookup google.com"
    run_client_probe "internet_ping_attempt" "ping -c 2 -W 2 8.8.8.8"
}

collect_q6() {
    # Uses doas, not sudo: sudo is not a real, independently-configured
    # command on the appliance (at most an alias), so relying on it here
    # would be fragile. doas -n requires a "permit nopass" rule for this
    # command in /etc/doas.d/ (see assignment setup notes).
    run_local "ruleset_dump" doas -n nft list ruleset

    # --- Management interface reachability -----------------------------
    # Stand-in "external management host": the client's OWN management
    # interface (eth1, 192.168.56.21), talking to the gateway's
    # management IP. Credential-free SSH-banner probe (no authenticated
    # login is attempted, since we have no client->gateway credentials).
    run_client_probe "mgmt_ssh_to_gateway" \
        "ncat --recv-only -w ${PROBE_TIMEOUT} -s 192.168.56.21 192.168.56.20 22"

    # --- Internal network: client <-> gateway ---------------------------
    run_client_probe "client_gateway_ssh" \
        "ncat --recv-only -w ${PROBE_TIMEOUT} 10.123.123.1 22"
    run_client_probe "client_gateway_icmp" \
        "ping -c 2 -W 2 10.123.123.1"

    # --- Client -> Internet, allowed protocols --------------------------
    run_client_probe "client_internet_icmp" \
        "ping -c 2 -W 2 8.8.8.8"
    run_client_probe "client_internet_ssh" \
        "ncat --recv-only -w ${PROBE_TIMEOUT} 8.8.8.8 22"
    run_client_probe "client_internet_http" \
        "wget -T ${PROBE_TIMEOUT} -q -O /dev/null http://www.ru.is && echo HTTP_OK"
    run_client_probe "client_internet_https" \
        "wget -T ${PROBE_TIMEOUT} -q -O /dev/null https://www.ru.is && echo HTTPS_OK"
    run_client_probe "client_internet_dns" \
        "nslookup google.com"

    # --- Blocked traffic: self-contained, no Internet dependency --------
    # The gateway briefly listens on an unapproved port on its internal
    # interface; the listener always terminates on its own (via `timeout`)
    # even if the client's probe never arrives. The client's probe is
    # expected to time out because the firewall's default-drop forward/
    # input policy should not permit this port.
    progress "client_blocked_port (starting ephemeral listener on gateway)"
    ( timeout 20 ncat -l -k "$BLOCKED_TEST_PORT" >/dev/null 2>&1 & )
    sleep 1
    run_client_probe "client_blocked_port" \
        "ncat --recv-only -w ${PROBE_TIMEOUT} 10.123.123.1 ${BLOCKED_TEST_PORT}"
}

collect_q7() {
    echo "NOTE: Q7 evidence should be collected AFTER rebooting both the gateway and the client VM." >&2

    # --- Gateway: persistent configuration + post-reboot runtime state --
    run_local "links" ip -br link
    run_local "addresses_ipv4" ip -br -4 addr
    run_local "routes_ipv4" ip -4 route
    run_local "network_interfaces_file" cat /etc/network/interfaces
    # Runtime value (post-reboot). Persistence itself is proven by
    # sysctl_conf_file below, not by this block.
    run_local "sysctl_forwarding" sysctl net.ipv4.ip_forward
    run_local "sysctl_conf_file" cat /etc/sysctl.conf
    run_local "rc_status" rc-status
    run_local "rc_update_show" rc-update show default
    run_local "nftables_conf_file" cat /etc/nftables.nft
    run_local "ruleset_dump" doas -n nft list ruleset

    # --- Client: persistent configuration + post-reboot runtime state ---
    run_remote_client "links" ip -br link
    run_remote_client "addresses_ipv4" ip -br -4 addr
    run_remote_client "routes_ipv4" ip -4 route
    run_remote_client "network_interfaces_file" cat /etc/network/interfaces
    run_remote_client "resolv_conf" cat /etc/resolv.conf
    run_client_probe "internet_ping_attempt" "ping -c 2 -W 2 8.8.8.8"
    run_client_probe "dns_attempt" "nslookup google.com"
}

# ---------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------

echo "==> Collecting evidence for ${QUESTION} (client: ${CLIENT_IP}) ..." >&2

file_header

case "$QUESTION" in
    Q2) collect_q2 ;;
    Q3) collect_q3 ;;
    Q4) collect_q4 ;;
    Q5) collect_q5 ;;
    Q6) collect_q6 ;;
    Q7) collect_q7 ;;
esac

file_footer

mv "$TEMP_FILE" "$OUTPUT_FILE"
echo "==> Done." >&2
echo "Evidence written to: $OUTPUT_FILE"
