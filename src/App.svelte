<script>
  import { onMount, tick } from "svelte";
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Key from "@lucide/svelte/icons/key-round";
  import Laptop from "@lucide/svelte/icons/laptop";
  import More from "@lucide/svelte/icons/ellipsis";
  import Phone from "@lucide/svelte/icons/smartphone";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Card from "$lib/components/ui/card";
  import KeyringScene from "./KeyringScene.svelte";
  import VaultMilestones from "./VaultMilestones.svelte";
  import VaultContents from "./VaultContents.svelte";
  import SetupDialog from "./SetupDialog.svelte";
  import { emptyWorkspace, readWorkspace, storageKey, writeWorkspace } from "./workspace.js";

  let workspace = $state(readWorkspace());
  let vaultName = $state("Personal vault");
  let email = $state("");
  let deviceName = $state("My phone");
  let attaching = $state(false);
  let sessionOnly = $state(false);
  let dialogOpen = $state(false);
  let dialogKind = $state("cloud");
  let dialogValue = $state("");
  let opener;
  let options = $state(null);
  let optionsButton = $state(null);
  let vaultHeading;
  let syncHeading;
  const { vault, account, device, example } = $derived(workspace);
  const stage = $derived(!vault ? "ready" : !account ? "local" : !device ? "cloud" : "linked");
  const syncTasks = {
    ready: { icon: Phone, label: "Up next · Step 2 of 2", title: "Link a second device through your cloud" },
    local: { icon: Cloud, label: "Step 2 of 2 · Link a device", title: "Connect your cloud account" },
    cloud: { icon: Phone, label: "Step 2 of 2 · Link a device", title: "Join from your second device" },
    linked: { icon: Check, label: "Device sync", title: "Your devices are in sync" },
  };
  const task = $derived(syncTasks[stage]);
  const membership = $derived(device ? "2 devices linked" : vault ? "1 device linked" : "0 devices linked");

  async function focusHeading(sync) {
    await tick();
    const heading = sync ? syncHeading : vaultHeading;
    if (!heading) return;
    heading.focus({ preventScroll: true });
    const rect = heading.getBoundingClientRect();
    if (rect.top < 0 || rect.bottom > innerHeight) heading.scrollIntoView({ block: "nearest" });
  }

  function followLink() {
    if (!location.hash) return;
    focusHeading(location.hash === "#vault/keyring" || location.hash.startsWith("#keyring"));
  }

  onMount(followLink);

  function save(next) {
    workspace = next;
    sessionOnly = !writeWorkspace(next);
  }

  function clearDrafts() {
    vaultName = "Personal vault";
    email = "";
    deviceName = "My phone";
    attaching = false;
  }

  function syncWorkspace(event) {
    if (event.key !== storageKey && event.key !== null) return;
    const previous = workspace;
    workspace = readWorkspace();
    sessionOnly = false;
    if (previous.vault === workspace.vault && previous.account === workspace.account && previous.device === workspace.device) return;
    attaching = false;
    dialogOpen = false;
    opener = null;
    if (previous.vault !== workspace.vault) clearDrafts();
    if (!workspace.vault) history.replaceState(null, "", location.pathname + location.search);
  }

  function createVault(event) {
    event.preventDefault();
    const name = vaultName.trim();
    if (stage !== "ready" || !name) return;
    attaching = true;
    save({ ...workspace, vault: name });
    focusHeading(false);
  }

  function connectAccount(event) {
    event.preventDefault();
    if (stage !== "local" || !email.trim()) return;
    attaching = false;
    save({ ...workspace, account: email.trim() });
    focusHeading(true);
  }

  function linkDevice(event) {
    event.preventDefault();
    const name = deviceName.trim();
    if (stage !== "cloud" || !name) return;
    save({ ...workspace, device: name });
    focusHeading(true);
  }

  function openDialog(kind, trigger) {
    dialogKind = kind;
    dialogValue = account;
    opener = trigger;
    dialogOpen = true;
  }

  function closeDialog(value) {
    if (!opener) return;
    if (value === null) {
      opener.focus();
    } else if (dialogKind === "reset") {
      save(emptyWorkspace());
      clearDrafts();
      history.replaceState(null, "", location.pathname + location.search);
      focusHeading(false);
    } else if (stage === "cloud") {
      save({ ...workspace, account: value });
      focusHeading(true);
    }
  }
</script>

<svelte:window onhashchange={followLink} onstorage={syncWorkspace} />
<svelte:head><title>{vault || "My keyring"} · Nook</title></svelte:head>

<header class="masthead">
  <div class="header-inner">
    <div class="brand">
      <span class="wordmark"><img src={import.meta.env.BASE_URL + "nook.svg"} alt="" width="23" height="23" />nook</span>
      <span class="brand-purpose">Local-first password manager</span>
    </div>
    <div class="header-actions">
      {#if sessionOnly}<span class="session-status" role="status">This session only</span>{/if}
      {#if vault}
        <nav class="workspace-links" aria-label="Workspace">
          <a href="#vault">Passwords</a><a href="#keyring">Keyring</a>
        </nav>
        <Button variant="ghost" size="icon" class="utility-button rounded-none" aria-label="Workspace actions"
          popovertarget="workspace-options" bind:ref={optionsButton}><More aria-hidden="true" /></Button>
        <div id="workspace-options" class="workspace-options" popover="auto" bind:this={options}>
          <button type="button" onclick={() => { options.hidePopover(); openDialog("reset", optionsButton); }}>Reset workspace…</button>
        </div>
      {/if}
    </div>
  </div>
</header>

<main class="workbench" data-stage={stage} aria-labelledby="vault">
  <section class="vault-workspace" aria-labelledby="vault">
    <div class="vault-identity">
      {#if vault}
        <span class="workspace-context"><Laptop aria-hidden="true" />Available offline on this device</span>
      {:else}
        <span class="chapter">Step 1 of 2</span>
      {/if}
      <h1 id="vault" tabindex="-1" title={vault || undefined} bind:this={vaultHeading}>{vault || "Create your local vault"}</h1>
    </div>
    <div class="vault-body">
      {#if vault}
        <VaultContents {example} onExample={(value) => save({ ...workspace, example: value })} />
      {:else}
        <form class="action-form" aria-label="Create a vault on this device" onsubmit={createVault}>
          <div class="field">
            <label for="vault-name">Vault name</label>
            <Input id="vault-name" class="setup-input rounded-none" bind:value={vaultName}
              pattern={".*\\S.*"} title="Enter a vault name" required autocomplete="off" />
          </div>
          <Button type="submit" class="action rounded-none">Create vault</Button>
        </form>
      {/if}
    </div>
    <div class="ring-view">
      <KeyringScene {stage} attach={attaching} />
      <p class="ring-caption" aria-live="polite"><Key aria-hidden="true" /><span class="ring-name">My keyring</span><span class="caption-rule" aria-hidden="true"></span>{membership}</p>
    </div>
  </section>

  <Card.Root class="setup-panel rounded-none" role="region" aria-labelledby="keyring">
    <div class="readiness">
      <div class="readiness-message">
        <span class="summary-icon" aria-hidden="true"><task.icon strokeWidth={1.7} /></span>
        <div class="summary-copy">
          <span class="chapter" id="sync-step">{task.label}</span>
          <h2 id="keyring" tabindex="-1" bind:this={syncHeading} aria-describedby="sync-step">{task.title}</h2>
          {#if stage === "cloud"}<p class="account-hint">Use the same account, <strong>{account}</strong>.</p>{/if}
        </div>
      </div>
      {#if stage === "local"}
        <form class="action-form" aria-label="Connect your own cloud account" onsubmit={connectAccount}>
          <div class="field">
            <label for="cloud-email">Cloud account email</label>
            <Input id="cloud-email" class="setup-input rounded-none" type="email" bind:value={email}
              placeholder="you@example.com" required autocomplete="off" autocapitalize="none" spellcheck={false} />
          </div>
          <Button type="submit" class="action rounded-none">Connect account</Button>
        </form>
      {:else if stage === "cloud"}
        <form class="action-form" aria-label="Link a second device through your cloud account" onsubmit={linkDevice}>
          <div class="field">
            <label for="device-name">Device name</label>
            <Input id="device-name" class="setup-input rounded-none" bind:value={deviceName}
              pattern={".*\\S.*"} title="Enter a device name" required autocomplete="off" />
          </div>
          <Button type="submit" class="action rounded-none">Link device</Button>
        </form>
      {/if}
    </div>
    <VaultMilestones {stage} {vault} {account} {device} onEdit={(trigger) => openDialog("cloud", trigger)} />
  </Card.Root>
</main>

<SetupDialog bind:open={dialogOpen} kind={dialogKind} bind:value={dialogValue} {vault} onReturn={closeDialog} />
