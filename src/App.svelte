<script>
  import { tick } from "svelte";
  import Check from "@lucide/svelte/icons/check";
  import Devices from "@lucide/svelte/icons/monitor-smartphone";
  import Drive from "@lucide/svelte/icons/hard-drive";
  import Keyring from "@lucide/svelte/icons/key-round";
  import More from "@lucide/svelte/icons/ellipsis";
  import Vault from "@lucide/svelte/icons/vault";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Card from "$lib/components/ui/card";
  import VaultMilestones from "./VaultMilestones.svelte";
  import VaultContents from "./VaultContents.svelte";
  import SetupDialog from "./SetupDialog.svelte";
  import { emptyWorkspace, readWorkspace, storageKey, writeWorkspace } from "./workspace.js";

  const initial = readWorkspace();
  let workspace = $state(initial);
  let view = $state(resolveView(initial.vault));
  let vaultName = $state("Personal vault");
  let email = $state("");
  let animationStage = $state("");
  let sessionOnly = $state(false);
  let dialogOpen = $state(false);
  let dialogKind = $state("device");
  let dialogValue = $state("");
  let workbench;
  let opener;
  let options = $state(null);
  let optionsButton = $state(null);
  const { vault, account, device, example } = $derived(workspace);
  const stage = $derived(!vault ? "ready" : !account ? "local" : !device ? "cloud" : "linked");
  const members = $derived(Number(!!vault) + Number(!!device));
  const pageTitle = $derived(view === "keyring" ? "My keyring" : vault);

  function resolveView(name) {
    if (!name && location.hash.startsWith("#vault")) {
      history.replaceState(null, "", location.pathname + location.search + "#keyring");
    }
    if (!name || location.hash === "#keyring") return "keyring";
    return location.hash === "#vault/keyring" ? "vault-keyring" : "vault";
  }

  function save(next) {
    workspace = next;
    sessionOnly = !writeWorkspace(next);
  }

  async function focusResult(selector) {
    await tick();
    const target = workbench?.querySelector(selector);
    if (!target) return;
    target.focus({ preventScroll: true });
    const bounds = target.getBoundingClientRect();
    if (bounds.top < 0 || bounds.bottom > innerHeight) {
      target.scrollIntoView({ block: "nearest", behavior: "instant" });
    }
  }

  function openView(focus = "#workspace-heading") {
    view = resolveView(workspace.vault);
    animationStage = "";
    focusResult(focus);
  }

  function syncWorkspace(event) {
    if (event.key !== storageKey && event.key !== null) return;
    const previous = workspace;
    const next = readWorkspace();
    workspace = next;
    sessionOnly = false;
    if (previous.vault === next.vault && previous.account === next.account && previous.device === next.device) return;
    dialogOpen = false;
    opener = null;
    animationStage = "";
    if (!next.vault || previous.vault !== next.vault) {
      vaultName = "Personal vault";
      email = "";
      openView();
    }
  }

  function createVault(event) {
    event.preventDefault();
    const name = vaultName.trim();
    if (stage !== "ready" || !name) return;
    animationStage = "local";
    save({ ...workspace, vault: name });
    history.pushState(null, "", "#vault/keyring");
    view = "vault-keyring";
    focusResult('[data-location="cloud"] h3');
  }

  function connectAccount(event) {
    event.preventDefault();
    if (stage !== "local" || !email.trim()) return;
    animationStage = "cloud";
    save({ ...workspace, account: email.trim() });
    focusResult('[data-location="device"] h3');
  }

  function openDialog(kind, trigger) {
    dialogKind = kind;
    dialogValue = kind === "device" ? "My phone" : account;
    opener = trigger;
    dialogOpen = true;
  }

  function closeDialog(value) {
    if (value === null || !opener) {
      opener?.focus();
      return;
    }
    if (dialogKind === "reset") {
      save(emptyWorkspace());
      email = "";
      vaultName = "Personal vault";
      history.replaceState(null, "", location.pathname + location.search);
      openView("#vault-name");
    } else if (dialogKind === "cloud" && stage === "cloud") {
      save({ ...workspace, account: value });
      focusResult('[data-location="device"] h3');
    } else if (dialogKind === "device" && stage === "cloud") {
      animationStage = "linked";
      save({ ...workspace, device: value });
      focusResult("#workspace-heading");
    }
  }
</script>

<svelte:window onhashchange={() => openView()} onstorage={syncWorkspace} />

<svelte:head><title>{pageTitle} · Nook</title></svelte:head>

<header class="masthead">
  <div class="brand">
    <span class="wordmark">
      <img src={import.meta.env.BASE_URL + "nook.svg"} alt="" width="23" height="23" />nook
    </span>
    <span class="brand-purpose">Password manager</span>
  </div>
  <div class="device-context">
    <Drive aria-hidden="true" />
    <span>{sessionOnly ? "This session only" : "This device"}</span>
    {#if vault}
      <Button
        variant="ghost"
        size="icon"
        class="utility-button rounded-none"
        aria-label="Workspace actions"
        popovertarget="workspace-options"
        bind:ref={optionsButton}
      ><More aria-hidden="true" /></Button>
      <div id="workspace-options" class="workspace-options" popover="auto" bind:this={options}>
        <button type="button" onclick={() => { options.hidePopover(); openDialog("reset", optionsButton); }}>
          Reset workspace…
        </button>
      </div>
    {/if}
  </div>
</header>

<div class="app-shell">
  <aside class="shelf">
    <nav aria-label="Workspace">
      <a class="shelf-link" href="#keyring" aria-current={view === "keyring" ? "page" : undefined}>
        <Keyring aria-hidden="true" /><span>My keyring</span>
      </a>
      <div class="vault-shelf">
        <span class="shelf-label">Vaults</span>
        {#if vault}
          <a class="shelf-link vault-link" href="#vault" aria-current={view !== "keyring" ? "page" : undefined} title={vault}>
            <Vault aria-hidden="true" />
            <span class="shelf-object">
              <strong>{vault}</strong>
              <small>{example ? "1 password" : "0 passwords"}</small>
            </span>
          </a>
        {:else}
          <span class="shelf-empty"><Vault aria-hidden="true" />No vault yet</span>
        {/if}
      </div>
    </nav>
  </aside>

  <main bind:this={workbench} class="workbench" data-stage={stage} data-view={view} aria-labelledby="workspace-heading">
    <header class="workspace-heading">
      <div class="object-heading">
        <span class="object-mark" aria-hidden="true">
          {#if view === "keyring"}<Keyring />{:else}<Vault />{/if}
        </span>
        <h1 id="workspace-heading" tabindex="-1" title={pageTitle}
          aria-describedby={device ? "member-count" : undefined}>{pageTitle}</h1>
      </div>
      <span id="member-count"><Devices aria-hidden="true" />
        {device ? "2 devices in sync" : members === 1 ? "1 device" : "0 devices"}
      </span>
    </header>

    {#if view !== "keyring" && vault}
      <VaultContents {stage} {example} inline={view === "vault-keyring"} onExample={(value) => save({ ...workspace, example: value })} />
    {/if}
    {#if view !== "vault"}
      <section class="resource-view" aria-labelledby="connections-heading">
        <div class="view-toolbar">
          <h2 id="connections-heading">Devices &amp; sync</h2>
          {#if device}
            <span class="linked-status"><Check aria-hidden="true" /> Keyring connected</span>
          {:else}
            <ol class="setup-steps" role="list" aria-label="Setup progress">
              <li class:complete={!!vault} aria-current={!vault ? "step" : undefined}>
                <span class="step-mark" aria-hidden="true">{#if vault}<Check />{:else}1{/if}</span>
                <span class="sr-only">Step 1 of 2. </span>{vault ? "Vault created" : "Create vault"}
              </li>
              <li aria-current={vault ? "step" : undefined}>
                <span class="step-mark" aria-hidden="true">2</span>
                <span class="sr-only">Step 2 of 2. </span>Link device
              </li>
            </ol>
          {/if}
        </div>
        <Card.Root class="setup-panel rounded-none">
          <VaultMilestones {stage} {vault} {account} {device} {animationStage} onEdit={(trigger) => openDialog("cloud", trigger)}>
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
                <Button type="submit" class="action rounded-none">Connect account</Button>
              </form>
            {:else if stage === "cloud"}
              <Button class="action rounded-none" aria-haspopup="dialog"
                onclick={(event) => openDialog("device", event.currentTarget)}>Link second device</Button>
            {/if}
          </VaultMilestones>
        </Card.Root>
      </section>
    {/if}
  </main>
</div>

<SetupDialog bind:open={dialogOpen} kind={dialogKind} bind:value={dialogValue} {vault} {account} onReturn={closeDialog} />
