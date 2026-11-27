# Nook keyring setup

Nook is a local-first, decentralized password manager. A **vault** holds your passwords. A **keyring** is the group of your devices that share access to that vault.

## Where the vault lives

**This device ↔ Your cloud account ↔ Another linked device**

Each linked device keeps an encrypted copy for offline use. Your own cloud storage account holds the only online sync copy. Devices encrypt changes locally and sync them in both directions through that account. If one device becomes unavailable, another linked device still has the vault.

## Two-step setup

1. **Create the vault on this device.** Name the vault to make this device the first member of your keyring. You can start locally before connecting cloud storage.
2. **Link another device.** Connect your own cloud account to save the encrypted sync copy. On the second device, use that same account and confirm joining the keyring.

## What the prototype implements

The setup UI uses Svelte 5 and shadcn-svelte. `App.svelte` keeps the vault name, cloud account label, and device name in memory. The keyring artwork and progress panel update together to show what is ready, what to do next, and why. Encryption, cloud sign-in, and cross-device sync are simulated.

To run locally, use `bun install --frozen-lockfile` followed by `bun --bun run dev`.

## GitHub Pages

Merges to `main` update the [live prototype](https://cypherkitty.github.io/nook-keyring-ui/). Each successful PR build publishes a preview at `/nook-keyring-ui/pr/<number>/`. Open **Pages preview** in the PR checks to see it. Closing or merging the PR removes its preview.
