"""Create BOOT.BIN for final SD-card solidification; never writes an SD card."""
from pathlib import Path
import argparse
import os
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]


def find_bootgen(tool_root: Path) -> Path:
    candidates = [
        tool_root / "Vivado/bin/unwrapped/win64.o/bootgen.exe",
        tool_root / "Vitis/bin/unwrapped/win64.o/bootgen.exe",
    ]
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    raise SystemExit("bootgen.exe not found under " + str(tool_root))


parser = argparse.ArgumentParser()
parser.add_argument("role", choices=("nav", "ax"))
parser.add_argument("--out", type=Path, required=True)
parser.add_argument("--tool-root", type=Path, default=Path(os.environ.get("AMD_2026_1", "E:/vivado2026.1/2026.1")))
parser.add_argument("--elf", type=Path, help="Use a newly built application.elf instead of the verified image.")
parser.add_argument("--fsbl", type=Path, help="Use an FSBL rebuilt from the matching XSA.")
parser.add_argument("--bit", type=Path, help="Use a newly built PL bitstream.")
args = parser.parse_args()
output = args.out.resolve()
if output.exists():
    raise SystemExit("Use a new output BOOT.BIN path")
role_dir = ROOT / "board" / ("navigator" if args.role == "nav" else "ax7020")
fsbl = args.fsbl.resolve() if args.fsbl else role_dir / "boot_sources/fsbl.elf"
bitstream = args.bit.resolve() if args.bit else role_dir / "jtag/system.bit"
application = args.elf.resolve() if args.elf else role_dir / "jtag/application.elf"
for required in (fsbl, bitstream, application):
    if not required.is_file():
        raise SystemExit(f"Missing BOOT input: {required}")
bootgen = find_bootgen(args.tool_root)
output.parent.mkdir(parents=True, exist_ok=True)
environment = os.environ.copy()
runtime_dirs = [args.tool_root / "Vivado/lib/win64.o", args.tool_root / "Vitis/lib/win64.o"]
environment["PATH"] = os.pathsep.join(str(path) for path in runtime_dirs if path.is_dir()) + os.pathsep + environment["PATH"]

with tempfile.TemporaryDirectory(prefix="boot_stage_", dir=output.parent) as temp:
    stage = Path(temp).resolve()
    for source, name in ((fsbl, "fsbl.elf"), (bitstream, "system.bit"), (application, "application.elf")):
        shutil.copy2(source, stage / name)
    (stage / "boot.bif").write_text(
        "the_ROM_image:\n{\n [bootloader] fsbl.elf\n system.bit\n application.elf\n}\n",
        encoding="ascii",
    )
    subprocess.run(
        [str(bootgen), "-arch", "zynq", "-image", "boot.bif", "-o", "BOOT.BIN"],
        cwd=stage, env=environment, check=True,
    )
    shutil.copy2(stage / "BOOT.BIN", output)
print("BOOT_CREATED " + str(output))
