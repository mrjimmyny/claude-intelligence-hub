#!/usr/bin/env python3
import argparse
import json
import os
import queue
import subprocess
import sys
import threading
from typing import Any, Dict, List, Optional


EXIT_WORDS = {"exit", "quit", ":q", "/exit", "/quit"}


class AppServerClient:
    def __init__(self, codex_path: str):
        self.process = subprocess.Popen(
            [codex_path, "app-server"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            bufsize=1,
        )
        self.stdout_queue: "queue.Queue[str]" = queue.Queue()
        self.stderr_queue: "queue.Queue[str]" = queue.Queue()
        self._request_id = 0
        self._start_reader(self.process.stdout, self.stdout_queue)
        self._start_reader(self.process.stderr, self.stderr_queue)

    def _start_reader(self, stream, target_queue: "queue.Queue[str]") -> None:
        def pump() -> None:
            for line in iter(stream.readline, ""):
                target_queue.put(line.rstrip("\r\n"))

        threading.Thread(target=pump, daemon=True).start()

    def next_request_id(self) -> str:
        self._request_id += 1
        return str(self._request_id)

    def send(self, payload: Dict[str, Any]) -> None:
        if self.process.stdin is None:
            raise RuntimeError("Codex app-server stdin is unavailable.")
        self.process.stdin.write(json.dumps(payload, separators=(",", ":")) + "\n")
        self.process.stdin.flush()

    def read_message(self, timeout: float) -> Optional[Dict[str, Any]]:
        try:
            line = self.stdout_queue.get(timeout=timeout)
        except queue.Empty:
            return None

        try:
            return json.loads(line)
        except json.JSONDecodeError:
            return {"method": "invalid/json", "raw": line}

    def request(self, method: str, params: Optional[Dict[str, Any]], timeout: float = 30.0) -> Dict[str, Any]:
        request_id = self.next_request_id()
        payload: Dict[str, Any] = {"id": request_id, "method": method}
        if params is not None:
            payload["params"] = params
        self.send(payload)

        while True:
            message = self.read_message(timeout)
            if message is None:
                raise TimeoutError(f"Timed out waiting for response to {method}.")
            if str(message.get("id")) == request_id:
                if "error" in message:
                    raise RuntimeError(f"{method} failed: {message['error']}")
                return message

    def initialize(self) -> None:
        self.request(
            "initialize",
            {"clientInfo": {"name": "codex-task-notifier", "version": "1.0.0"}},
            timeout=15.0,
        )
        self.send({"method": "initialized"})

    def close(self) -> None:
        if self.process.poll() is None:
            self.process.kill()


def truncate_text(text: str, max_len: int) -> str:
    normalized = " ".join((text or "").split())
    if len(normalized) <= max_len:
        return normalized
    return normalized[: max_len - 3].rstrip() + "..."


def _to_sandbox_policy_type(sandbox_mode: str) -> str:
    mapping = {
        "danger-full-access": "dangerFullAccess",
        "read-only": "readOnly",
        "workspace-write": "workspaceWrite",
    }
    return mapping[sandbox_mode]


def build_payload(
    *,
    prompt_text: str,
    final_text: str,
    turn_status: str,
    thread_id: str,
    turn_id: str,
    cwd: str,
) -> Dict[str, Any]:
    completed = turn_status == "completed"
    summary = final_text.strip() if final_text.strip() else f"Turn finished with status '{turn_status}' and no final agent message."
    title_prefix = "Task completed" if completed else "Task finished"

    return {
        "type": "task.completed" if completed else "task.failed",
        "status": turn_status,
        "session_id": thread_id,
        "thread_id": thread_id,
        "turn_id": turn_id,
        "cwd": cwd,
        "title": f"{title_prefix}: {truncate_text(prompt_text, 120)}",
        "summary": summary,
        "prompt": prompt_text,
    }


def send_notification(entrypoint: str, payload: Dict[str, Any]) -> subprocess.CompletedProcess:
    return subprocess.run(
        [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            entrypoint,
        ],
        input=json.dumps(payload),
        text=True,
        capture_output=True,
        check=False,
    )


def print_monitor_banner(cwd: str, approval_policy: str, sandbox: str) -> None:
    sys.stdout.write("codex-task-notifier monitored session\n")
    sys.stdout.write(f"cwd: {cwd}\n")
    sys.stdout.write(f"approval: {approval_policy} | sandbox: {sandbox}\n")
    sys.stdout.write("emails are emitted on every completed turn in this launcher.\n")
    sys.stdout.write("type 'exit' to close the session.\n\n")
    sys.stdout.flush()


def create_thread(client: AppServerClient, cwd: str, approval_policy: str, sandbox: str, model: Optional[str]) -> str:
    params: Dict[str, Any] = {
        "cwd": cwd,
        "approvalPolicy": approval_policy,
        "sandbox": sandbox,
    }
    if model:
        params["model"] = model

    response = client.request("thread/start", params, timeout=30.0)
    thread = response.get("result", {}).get("thread", {})
    thread_id = thread.get("id")
    if not thread_id:
        raise RuntimeError("thread/start did not return a thread id.")
    return thread_id


def run_turn(
    client: AppServerClient,
    *,
    thread_id: str,
    prompt_text: str,
    cwd: str,
    approval_policy: str,
    sandbox: str,
    model: Optional[str],
) -> Dict[str, Any]:
    params: Dict[str, Any] = {
        "threadId": thread_id,
        "cwd": cwd,
        "approvalPolicy": approval_policy,
        "sandboxPolicy": {"type": _to_sandbox_policy_type(sandbox)},
        "input": [{"type": "text", "text": prompt_text}],
    }
    if model:
        params["model"] = model

    response = client.request("turn/start", params, timeout=30.0)
    turn = response.get("result", {}).get("turn", {})
    turn_id = turn.get("id")
    if not turn_id:
        raise RuntimeError("turn/start did not return a turn id.")

    final_text = ""
    printed_delta = False
    turn_status = "unknown"
    turn_error = None

    while True:
        message = client.read_message(timeout=120.0)
        if message is None:
            raise TimeoutError("Timed out waiting for turn events.")

        method = message.get("method")
        payload = message.get("params", {})

        if method == "item/agentMessage/delta":
            delta = payload.get("delta", "")
            if delta:
                sys.stdout.write(delta)
                sys.stdout.flush()
                printed_delta = True
            continue

        if method == "item/completed":
            item = payload.get("item", {})
            if item.get("type") == "agentMessage":
                final_text = item.get("text", "") or final_text
            continue

        if method == "turn/completed":
            turn_data = payload.get("turn", {})
            turn_status = turn_data.get("status", "unknown")
            turn_error = turn_data.get("error")
            if printed_delta:
                sys.stdout.write("\n")
            elif final_text:
                sys.stdout.write(final_text + "\n")
            elif turn_error:
                sys.stdout.write(f"[turn {turn_status}] {turn_error}\n")
            else:
                sys.stdout.write(f"[turn {turn_status}]\n")
            sys.stdout.flush()
            break

    return {
        "thread_id": thread_id,
        "turn_id": turn_id,
        "status": turn_status,
        "final_text": final_text,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Run a monitored Codex session and email on turn completion.")
    parser.add_argument("--codex-path", required=True)
    parser.add_argument("--entrypoint", required=True)
    parser.add_argument("--cwd", default=os.getcwd())
    parser.add_argument("--approval-policy", default="on-request", choices=["untrusted", "on-request", "never"])
    parser.add_argument("--sandbox", default="workspace-write", choices=["read-only", "workspace-write", "danger-full-access"])
    parser.add_argument("--model")
    parser.add_argument("--once", help="Run a single prompt and exit.")
    parser.add_argument("--quiet-banner", action="store_true")
    args = parser.parse_args()

    client = AppServerClient(args.codex_path)
    try:
        client.initialize()
        thread_id = create_thread(client, args.cwd, args.approval_policy, args.sandbox, args.model)

        if not args.quiet_banner:
            print_monitor_banner(args.cwd, args.approval_policy, args.sandbox)

        prompts: List[str]
        if args.once:
            prompts = [args.once]
        else:
            prompts = []

        while True:
            if prompts:
                prompt_text = prompts.pop(0)
            else:
                try:
                    prompt_text = input("you> ").strip()
                except EOFError:
                    break

            if not prompt_text:
                continue

            if prompt_text.lower() in EXIT_WORDS:
                break

            turn_result = run_turn(
                client,
                thread_id=thread_id,
                prompt_text=prompt_text,
                cwd=args.cwd,
                approval_policy=args.approval_policy,
                sandbox=args.sandbox,
                model=args.model,
            )

            payload = build_payload(
                prompt_text=prompt_text,
                final_text=turn_result["final_text"],
                turn_status=turn_result["status"],
                thread_id=turn_result["thread_id"],
                turn_id=turn_result["turn_id"],
                cwd=args.cwd,
            )
            notification = send_notification(args.entrypoint, payload)
            if notification.returncode != 0:
                sys.stderr.write("codex-task-notifier: failed to invoke notification entrypoint.\n")
                if notification.stderr:
                    sys.stderr.write(notification.stderr)
                sys.stderr.flush()

            if args.once:
                break

        return 0
    finally:
        client.close()


if __name__ == "__main__":
    sys.exit(main())
