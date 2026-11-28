# Nook local keyring

Nook is a local-first, decentralized password manager. A **vault** holds your passwords. A **keyring** is the group of your devices that share access to that vault. The main page opens directly in **My keyring**, where you create the vault, use your passwords, and link devices.

## Where the vault lives

**This device ↔ Your cloud account ↔ Another linked device**

Each linked device keeps an encrypted copy for offline use. Your own cloud storage account holds the only online sync copy. Devices encrypt changes locally and sync them in both directions through that account. If one device becomes unavailable, another linked device still has the vault.

## Two-step setup

**Step 1** creates a usable vault on this device before any cloud connection. **Step 2** links another device through your own cloud account. Only devices count as keyring members.

| Workspace state | Step shown | Devices | What changes on screen |
| --- | --- | ---: | --- |
| First visit | 1 of 2 | 0 | The orange tag waits beside the steel ring. Name the vault to create it on this device. |
| Vault created | 2 of 2 | 1 | The orange device tag joins the ring. The password list opens immediately, and the next action connects personal storage. |
| Cloud connected | 2 of 2 | 1 | The silver tag marks the encrypted sync copy. Open Nook on the second device with the same account to join. |
| Second device linked | Complete | 2 | The graphite tag completes the ring. The menu shows the new device’s name. Both devices open the same named vault. |

## What the prototype implements

The Svelte 5 and shadcn-svelte app keeps all three locations in a progress menu above the current action. Selecting a location shows its action, prerequisite, or saved details. The cloud account can be changed until the second device joins.

Encryption, cloud sign-in, and cross-device sync are simulated. `src/workspace.js` saves the vault name, account label, device name, and presence of a fixed example login in browser local storage, scoped to each deployment path. Reloading restores the password list and setup progress. Tabs on the same deployment share updates. If a save cannot persist, the app shows **This session only**.

To run locally, use `bun install --frozen-lockfile` followed by `bun --bun run dev`.

For guidance on the first screen, progress menu, and keyring artwork, see [UX guidance for Nook](AGENTS.md).

## GitHub Pages

GitHub Actions publishes the static app when changes merge into `main`. [Live prototype](https://cypherkitty.github.io/nook-keyring-ui/)

Each successful PR build publishes a preview at `/nook-keyring-ui/pr/<number>/`. Open **Pages preview** in the PR checks to see it. Closing or merging the PR removes its preview.
