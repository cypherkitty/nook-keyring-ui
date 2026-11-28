<script>
  import { onMount, tick } from "svelte";
  import More from "@lucide/svelte/icons/ellipsis";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import KeyringScene from "./KeyringScene.svelte";
  import VaultMilestones from "./VaultMilestones.svelte";
  import VaultContents from "./VaultContents.svelte";
  import SetupDialog from "./SetupDialog.svelte";
  import { emptyWorkspace, readWorkspace, storageKey, writeWorkspace } from "./workspace.js";

  let workspace = $state(readWorkspace());
  let vaultName = $state("Personal vault");
  let email = $state("");
  let deviceName = $state("My phone");
  let lastAttachment = $state("");
  let sessionOnly = $state(false);
  let dialogOpen = $state(false);
  let dialogKind = $state("cloud");
  let dialogValue = $state("");
  let opener;
  let options = $state(null);
  let optionsButton = $state(null);
  const { vault, account, device, example } = $derived(workspace);
  const stage = $derived(!vault ? "ready" : !account ? "local" : !device ? "cloud" : "linked");
  const membershipByStage = {
    ready: "0 devices linked",
    local: "1 device · Local only",
    cloud: "1 device · Cloud connected",
    linked: "2 devices in sync",
  };

  async function focusSection(id) {
    await tick();
    const heading = document.getElementById(id);
    if (!heading) return;
    heading.focus({ preventScroll: true });
    const rect = heading.getBoundingClientRect();
    if (rect.top < 0 || rect.bottom > innerHeight) heading.scrollIntoView({ block: "nearest" });
  }

  function followLink() {
    switch (location.hash) {
      case "#vault": return focusSection(vault ? "vault" : "location-vault");
      case "#keyring/cloud": return focusSection("location-cloud");
      case "#keyring/device": return focusSection("location-device");
      case "#vault/keyring":
      case "#keyring": return focusSection("keyring");
    }
  }

  onMount(() => { followLink(); });

  function save(next) {
    workspace = next;
    sessionOnly = !writeWorkspace(next);
  }

  function clearDrafts() {
    vaultName = "Personal vault";
    email = "";
    deviceName = "My phone";
    lastAttachment = "";
  }

  function syncWorkspace(event) {
    if (event.key !== storageKey && event.key !== null) return;
    const previous = workspace;
    workspace = readWorkspace();
    sessionOnly = false;
    if (previous.vault === workspace.vault && previous.account === workspace.account && previous.device === workspace.device) return;
    lastAttachment = "";
    dialogOpen = false;
    opener = null;
    if (previous.vault !== workspace.vault) clearDrafts();
    if (!workspace.vault) history.replaceState(null, "", location.pathname + location.search);
  }

  function createVault(event) {
    event.preventDefault();
    const name = vaultName.trim();
    if (stage !== "ready" || !name) return;
    lastAttachment = "vault";
    save({ ...workspace, vault: name });
    focusSection("location-cloud");
  }

  function connectAccount(event) {
    event.preventDefault();
    if (stage !== "local" || !email.trim()) return;
    lastAttachment = "cloud";
    save({ ...workspace, account: email.trim() });
    focusSection("location-device");
  }

  function linkDevice(event) {
    event.preventDefault();
    const name = deviceName.trim();
    if (stage !== "cloud" || !name) return;
    lastAttachment = "device";
    save({ ...workspace, device: name });
    focusSection("location-device");
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
      focusSection("vault-name");
    } else if (stage === "cloud") {
      save({ ...workspace, account: value });
      focusSection("location-device");
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
          <a href="#keyring">Keyring</a><a href="#vault">Passwords</a>
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

<main class="workbench" data-stage={stage} aria-labelledby="keyring">
  <section class="keyring-workspace" aria-labelledby="keyring">
    <header class="keyring-heading">
      <h1 id="keyring" tabindex="-1">My keyring</h1>
      <p class="membership" aria-live="polite" aria-atomic="true">{membershipByStage[stage]}</p>
    </header>

    <VaultMilestones {stage} {vault} {account} {device} {lastAttachment}
      onEdit={(trigger) => openDialog("cloud", trigger)}>
      {#if stage === "ready"}
        <form class="action-form" aria-label="Create a vault on this device" onsubmit={createVault}>
          <div class="field">
            <label for="vault-name">Vault name</label>
            <Input id="vault-name" class="setup-input rounded-none" bind:value={vaultName}
              pattern={".*\\S.*"} title="Enter a vault name" required autocomplete="off" />
          </div>
          <Button type="submit" class="action rounded-none">Create vault</Button>
        </form>
      {:else if stage === "local"}
        <form class="action-form" aria-label="Connect your own cloud account" onsubmit={connectAccount}>
          <div class="field">
            <label for="cloud-email">Cloud account email</label>
            <Input id="cloud-email" class="setup-input rounded-none" type="email" bind:value={email}
              placeholder="you@example.com" required autocomplete="off" autocapitalize="none" spellcheck={false} />
          </div>
          <Button type="submit" class="action rounded-none" aria-label="Connect account">Connect</Button>
        </form>
      {:else if stage === "cloud"}
        <form class="action-form" aria-label="Join from the second device with the same cloud account" onsubmit={linkDevice}>
          <div class="field">
            <label for="device-name">Device name</label>
            <Input id="device-name" class="setup-input rounded-none" bind:value={deviceName} aria-describedby="join-account"
              pattern={".*\\S.*"} title="Enter a device name" required autocomplete="off" />
          </div>
          <Button type="submit" class="action rounded-none">Link device</Button>
        </form>
      {/if}
    </VaultMilestones>

    <div class="ring-view">
      <KeyringScene {stage} attach={lastAttachment === "vault"} />
    </div>
  </section>

  {#if vault}
    <VaultContents {vault} {example} onExample={(value) => save({ ...workspace, example: value })} />
  {/if}
</main>

<SetupDialog bind:open={dialogOpen} kind={dialogKind} bind:value={dialogValue} {vault} onReturn={closeDialog} />
