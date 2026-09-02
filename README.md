# nixos-apple-silicon kernel cache

This public flake tracks
[`nix-community/nixos-apple-silicon`](https://github.com/nix-community/nixos-apple-silicon),
builds its `linux-asahi` kernel natively on AArch64, and publishes the complete
runtime closure as an immutable GitHub Release.

There are two cache layers:

- [Magic Nix Cache](https://github.com/DeterminateSystems/magic-nix-cache-action)
  accelerates this repository's GitHub Actions builds.
- GitHub Releases provide public, manually importable Nix closure archives.

Magic Nix Cache is not a public Nix substituter. Importing a release archive is
therefore an explicit step.

## Flake package

The flake exposes both `packages.aarch64-linux.linux-asahi` and the default
AArch64 package:

```console
nix build github:<owner>/<repo>#linux-asahi
```

A NixOS configuration can use the exported kernel directly:

```nix
{
  inputs.asahi-kernel.url = "github:<owner>/<repo>";

  outputs = { nixpkgs, asahi-kernel, ... }: {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ({ pkgs, ... }: {
          boot.kernelPackages = pkgs.linuxPackagesFor
            asahi-kernel.packages.aarch64-linux.linux-asahi;
        })
      ];
    };
  };
}
```

For a reproducible match with an imported closure, use the exact repository tag
shown by that release rather than the moving default branch.

## Import a release

Download the `.tar.zst` archive and its adjacent `.sha256` file from the
matching release. From the directory containing both files:

```console
archive=linux-asahi-<version>-<revision>-aarch64-linux.nix-store-export.tar.zst
sha256sum --check "$archive.sha256"
tar --zstd -xOf "$archive" closure.nix-store-export | sudo nix-store --import
```

Each archive also contains:

- `IMPORT.md` with commands and the exact tagged flake reference;
- `manifest.json` with kernel, upstream, repository, and store-path provenance;
- `kernel-output-paths.txt` listing the kernel's `out`, `modules`, and `dev`
  outputs;
- `closure-paths.txt` listing every imported store path.

After importing, a build using the release's exact flake tag should reuse the
imported kernel instead of compiling it.

## Automation

Dependabot checks the upstream Nix flake input daily. Its Nix update pull
requests are built on GitHub's native `ubuntu-24.04-arm` runner and configured
for squash auto-merge after required checks pass. Once merged, the main-branch
workflow builds the locked kernel and publishes one release tagged:

```text
nixos-apple-silicon-<full-upstream-git-revision>
```

Re-running the workflow for an already-published upstream revision is a no-op.
Pull requests never publish releases.

## Required repository settings

- Keep the repository public; the standard native ARM64 runner is only
  available without charge to public repositories.
- Enable GitHub auto-merge.
- Protect `main` and require the `kernel-build` check before merging.
- Permit GitHub Actions to create releases using the workflow `GITHUB_TOKEN`.

The kernel and its closure retain their respective upstream licenses.
