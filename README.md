# Nook local keyring

Nook is a local-first, decentralized password manager. A **vault** holds your passwords. A **keyring** is the group of your devices that share access to that vault.

## Where the vault lives

**This device ↔ Your cloud account ↔ Another linked device**

Each linked device keeps an encrypted copy for offline use. Your own cloud storage account holds the only online sync copy. Devices encrypt changes locally and sync them in both directions through that account. If one device becomes unavailable, another linked device still has the vault.

## Two-step setup

1. **Create the vault on this device.** Name the vault to make this device the first member of your keyring. You can start locally before connecting cloud storage.
2. **Link another device.** Connect your own cloud account to save the encrypted sync copy. On the second device, use that same account and confirm joining the keyring.

## What the prototype implements

The Svelte 5 and shadcn-svelte app opens directly in the vault workspace. Creating a vault replaces the name field with its password list. You can use the list while linking another device below it. The keyring artwork gains a tag and the corresponding progress indicator updates as each encrypted copy is added. Returning to the main URL reopens the saved vault.

`src/workspace.js` saves the vault name, account label, device name, and presence of a built-in example in this browser’s local storage. Each deployment path has its own record. The password list accepts a fixed example login. Encryption, cloud sign-in, and cross-device sync are simulated.

To run locally, use `bun install --frozen-lockfile` followed by `bun --bun run dev`.

For onboarding design principles and their sources, see [UX guidance for Nook](AGENTS.md).

## GitHub Pages

Merges to `main` update the [live prototype](https://cypherkitty.github.io/nook-keyring-ui/). Each successful PR build publishes a preview at `/nook-keyring-ui/pr/<number>/`. Open **Pages preview** in the PR checks to see it. Closing or merging the PR removes its preview.
