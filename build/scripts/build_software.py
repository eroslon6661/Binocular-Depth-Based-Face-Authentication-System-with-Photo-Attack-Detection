"""Build either Zynq-7020 bare-metal application with the AMD 2026.1 ARM GCC."""
from pathlib import Path
import argparse
import hashlib
import json
import os
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def default_compiler() -> Path:
    candidates = [
        os.environ.get("ARM_GCC"),
        "E:/vivado2026.1/2026.1/gnu/aarch32/nt/gcc-arm-none-eabi/bin/arm-none-eabi-gcc.exe",
    ]
    for value in candidates:
        if value and Path(value).is_file():
            return Path(value)
    return Path(candidates[-1])


def require_ascii_path(path: Path) -> None:
    try:
        str(path.resolve()).encode("ascii")
    except UnicodeEncodeError as exc:
        raise SystemExit(
            "The AMD Windows ARM linker requires an ASCII-only absolute path. "
            "Copy this package to a path such as F:/fpga_project and run again."
        ) from exc


def build(role: str, output: Path, compiler: Path, source_override=None, bsp_override=None, cpu1_override=None) -> None:
    require_ascii_path(ROOT)
    key = "navigator" if role == "nav" else "ax7020"
    config = json.loads((ROOT / "project_config.json").read_text(encoding="utf-8"))[key]
    source = Path(source_override).resolve() if source_override else ROOT / config["source"]
    bsp = Path(bsp_override).resolve() if bsp_override else ROOT / config["bsp"]
    def blob_path(blob):
        if cpu1_override and blob['path'].endswith('/crc_core1.bin'):return Path(cpu1_override).resolve()
        return ROOT / blob['path']
    output = output.resolve()
    if output.exists():
        raise SystemExit(f"Use a new output directory: {output}")
    required = [source, bsp, ROOT / config["linker"], compiler]
    for path in required:
        if not path.exists():
            raise SystemExit(f"Missing required file or directory: {path}")
    for group in config["assembly"]:
        for blob in group["blobs"]:
            if not blob_path(blob).is_file():
                raise SystemExit(f"Missing embedded data: {blob['path']}")

    output.mkdir(parents=True)
    object_dir = output / "obj"
    object_dir.mkdir()
    flags = [
        "-mcpu=cortex-a9", "-mfpu=vfpv3", "-mfloat-abi=hard", "-O3", "-g",
        "-Wall", "-Wextra", "-ffunction-sections", "-fdata-sections",
        "-DLWIP_ALLOW_MEM_FREE_FROM_OTHER_CONTEXT=1",
        "-DDB_CACHE_IRQ_SLICE_BYTES=32768U", "-DDB_ONE_WAY=1",
        "-DVOICE_CODEC_BOUNDED_IIC=1", f"-I{source}", f"-I{bsp / 'include'}",
        f"-I{bsp / 'include/lwip'}",
    ]
    if role == "ax":
        flags += ["-DDB_PLCRC_ENABLE=1", "-DDB_PHY_WAIT_FOR_LINK=1"]
    port = next(bsp.glob("libsrc/lwip*/src/contrib/ports/xilinx"))
    flags += [f"-I{port / part}" for part in ("include", "include/netif", "netif", ".")]

    objects = []
    for source_file in sorted(source.rglob("*.c")):
        if role == "ax" and source_file.name in ("db_live_sequence.c", "db_live_burst.c"):
            continue
        destination = object_dir / (source_file.relative_to(source).as_posix().replace("/", "_") + ".o")
        extra = ["-mfpu=neon"] if source_file.name in ("db_preview_pixels.c", "db_preview_shading.c") else []
        subprocess.run([str(compiler), *flags, *extra, "-c", str(source_file), "-o", str(destination)], check=True)
        objects.append(str(destination))

    for index, group in enumerate(config["assembly"]):
        lines = [f'.section {group["section"]},"a"']
        for blob in group["blobs"]:
            lines += [
                f'.balign {group["alignment"]}', f'.global {blob["start"]}',
                f'{blob["start"]}:', f'.incbin "{blob_path(blob).as_posix()}"',
            ]
            if blob.get("end"):
                lines += [f'.global {blob["end"]}', f'{blob["end"]}:']
        assembly = output / f"embedded_{index}.S"
        assembly.write_text("\n".join(lines) + "\n", encoding="ascii")
        destination = object_dir / (assembly.name + ".o")
        subprocess.run([str(compiler), *flags, "-c", str(assembly), "-o", str(destination)], check=True)
        objects.append(str(destination))

    linker = output / "lscript.ld"
    shutil.copy2(ROOT / config["linker"], linker)
    runtime = {
        name: subprocess.check_output([str(compiler), *flags, "-print-file-name=" + name], text=True).strip()
        for name in ("crti.o", "crtbegin.o", "crtend.o", "crtn.o")
    }
    elf = output / "application.elf"
    subprocess.run([
        str(compiler), *flags, "-nostartfiles", runtime["crti.o"], runtime["crtbegin.o"],
        *objects, f"-Wl,-T,{linker}", "-Wl,--gc-sections", f"-Wl,-Map,{output / 'application.map'}",
        f"-L{bsp / 'lib'}", "-Wl,--start-group", "-lxil", "-llwip4", "-lm", "-lc", "-lgcc",
        "-Wl,--end-group", runtime["crtend.o"], runtime["crtn.o"], "-o", str(elf),
    ], check=True)
    manifest = {
        "role": role, "tool_version": "2026.1", "elf": str(elf), "sha256": sha256(elf),
        "full_source_build": True, "board_tested": False,
        "source_directory": str(source), "bsp_directory": str(bsp),
        "bsp_sha256": {p.name:sha256(p) for p in (bsp/'lib').glob('*.a')},
        "embedded_data_sha256": {b['path']:sha256(blob_path(b)) for g in config['assembly'] for b in g['blobs']},
        "source_sha256": {p.relative_to(source).as_posix(): sha256(p) for p in source.rglob("*") if p.is_file()},
    }
    (output / "build_manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"FULL_SOURCE_LINK_PASS role={role} sha256={sha256(elf)}", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("role", choices=("nav", "ax"))
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--compiler", type=Path, default=default_compiler())
    parser.add_argument("--source", type=Path, help="Optional diagnostic source copy; default preserves release sources")
    parser.add_argument("--bsp", type=Path, help="Optional newly rebuilt BSP directory")
    parser.add_argument("--cpu1", type=Path, help="Optional newly rebuilt CPU1 binary")
    arguments = parser.parse_args()
    build(arguments.role, arguments.out, arguments.compiler, arguments.source, arguments.bsp, arguments.cpu1)
