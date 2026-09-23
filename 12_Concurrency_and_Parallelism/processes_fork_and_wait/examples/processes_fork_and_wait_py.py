"""os.fork copies the process; os.waitpid collects its status -- the twin.

Same rows as the Ruby program. Two things Python makes you do by hand: flush
stdout before forking (the child inherits the buffer, and would print it
again), and leave the child with os._exit() so it does not run the parent's
exit handlers. subprocess.run is spawn/system/backticks in one call.
"""
import os
import signal
import subprocess
import sys


def row(n, label, value):
    print(f"{n:2d}. {label:<52} {value}")


def fork_flushed():
    sys.stdout.flush()
    return os.fork()


def main():
    # 1. fork; the child exits with 3; the parent waits and decodes the status
    pid = fork_flushed()
    if pid == 0:
        os._exit(3)
    _, status = os.waitpid(pid, 0)
    code = os.waitstatus_to_exitcode(status)
    row(1, "os.fork(); child os._exit(3); waitpid; exit code / == 0", f"{code} / {code == 0}")

    # 2-3. fork returns twice: 0 in the child, the pid in the parent
    pid = fork_flushed()
    if pid == 0:
        row(2, "fork returned 0: this row is printed by the child", "child")
        sys.stdout.flush()
        os._exit(0)
    os.waitpid(pid, 0)
    row(3, "fork returned a positive int: printed by the parent", f"parent (pid > 0: {pid > 0})")

    # 4. The child gets a copy of every object; it reports through a pipe
    counter = 0
    reader, writer = os.pipe()
    pid = fork_flushed()
    if pid == 0:
        os.close(reader)
        counter += 1
        os.write(writer, str(counter).encode())
        os.close(writer)
        os._exit(0)
    os.close(writer)
    report = os.read(reader, 100).decode()
    os.close(reader)
    os.waitpid(pid, 0)
    row(4, "child did counter += 1 and wrote it / parent's counter", f"{report} / {counter}")

    # 5. waitpid returns the pid and the raw status together
    pid = fork_flushed()
    if pid == 0:
        os._exit(7)
    _, status = os.waitpid(pid, 0)
    row(5, "os.waitpid(pid, 0) -> (pid, status); WEXITSTATUS", f"{type(status).__name__}, exit code {os.WEXITSTATUS(status)}")

    # 6. subprocess.Popen starts another program; wait() collects it
    row(6, "Popen([python, -c, \"raise SystemExit(5)\"]).wait()", f"returncode {subprocess.Popen([sys.executable, '-c', 'raise SystemExit(5)']).wait()}")

    # 7. subprocess.run: returncode 0 / 2 / FileNotFoundError
    ok = subprocess.run([sys.executable, "-c", "raise SystemExit(0)"]).returncode
    failed = subprocess.run([sys.executable, "-c", "raise SystemExit(2)"]).returncode
    try:
        subprocess.run(["no_such_command_xyz_123"])
    except FileNotFoundError as e:
        missing = type(e).__name__
    row(7, "run(...).returncode: exit 0 / exit 2 / a missing command", f"{ok} / {failed} / {missing}")

    # 8. capture_output=True captures the child's stdout
    done = subprocess.run([sys.executable, "-c", "print(40 + 2, end='')"], capture_output=True, text=True)
    row(8, "run(capture_output=True).stdout; returncode == 0", f"{done.stdout!r} / {done.returncode == 0}")

    # 9. A child killed by a signal: a negative exit code
    pid = fork_flushed()
    if pid == 0:
        import time
        time.sleep(5)
        os._exit(0)
    os.kill(pid, signal.SIGTERM)
    _, status = os.waitpid(pid, 0)
    row(9, "killed by SIGTERM: exit code / WIFSIGNALED / signal", f"{os.waitstatus_to_exitcode(status)} / {os.WIFSIGNALED(status)} / {signal.Signals(os.WTERMSIG(status)).name}")

    # 10. Nothing left to wait for
    try:
        os.wait()
    except ChildProcessError as e:
        row(10, "os.wait() with no children left", type(e).__name__)


if __name__ == "__main__":
    main()
