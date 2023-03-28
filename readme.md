# Canto Archive Node Setup Wizard

This repository contains a Bash script `cosmovisor-setup.bash` which can be used to quickly and easily begin syncing an archive node for Canto mainnet (7700).

The script uses Cosmovisor to automatically switch between binaries at historical upgrade blocks, as well as the patched v2.0.2 binary to mitigate AppHash errors.

Contributions are welcome!

## Getting Started

First, download the script:

```
wget https://raw.githubusercontent.com/tster/canto-archive-node/main/cosmovisor-setup.bash
```

Then, run the script:

```
bash cosmovisor-setup.bash
```