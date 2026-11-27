<script>
  import { tick } from "svelte";
  import { Button } from "$lib/components/ui/button";
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Plus from "@lucide/svelte/icons/plus";
  import Phone from "@lucide/svelte/icons/smartphone";
  import Restart from "@lucide/svelte/icons/rotate-ccw";
  import KeyringScene from "./KeyringScene.svelte";
  import SetupDialog from "./SetupDialog.svelte";

  // The prototype keeps only the display names for this setup session.
  let vault = $state("");
  let account = $state("");
  let device = $state("");
  let dialogOpen = $state(false);
  let dialogKind = $state("vault");
  let draft = $state("");
  let opener;
  let heading;

  const next = $derived(
    !vault ? "vault" : !account ? "cloud" : !device ? "device" : null,
  );
  const actions = {
    vault: { icon: Plus, label: "Create local vault" },
    cloud: { icon: Cloud, label: "Connect cloud account" },
    device: { icon: Phone, label: "Open second-device preview" },
  };

  function openSetup(kind, trigger) {
    dialogKind = kind;
    draft =
      kind === "vault"
        ? "Personal vault"
        : kind === "cloud"
          ? account || "you@example.com"
          : "My phone";
    opener = trigger;
    dialogOpen = true;
  }

  function save(kind, value) {
    if (kind === "vault") vault = value;
    else if (kind === "cloud") account = value;
    else device = value;
  }

  async function returnFocus(confirmed) {
    await tick();
    if (!confirmed && opener?.isConnected) opener.focus();
    else heading?.focus();
  }

  async function restart() {
    vault = "";
    account = "";
    device = "";
    draft = "";
    await tick();
    heading?.focus();
  }
</script>

<header class="masthead">
  <div class="brand">
    <span class="wordmark">
      <img src="/nook.svg" alt="" width="30" height="30" />nook
    </span>
    <span class="brand-purpose">Local-first password manager</span>
  </div>
  {#if vault}
    <Button variant="ghost" class="restart rounded-none" onclick={restart}>
      <Restart aria-hidden="true" />Restart preview
    </Button>
  {:else}
    <span class="preview-label">Setup preview</span>
  {/if}
</header>

<main class="workspace" aria-labelledby="setup-heading">
  <div class="introduction">
    {#if !device}
      <div class="phase">
        <span class="phase-rule" aria-hidden="true">
          <i></i><i class:filled={!!vault}></i>
        </span>
        Step {vault ? 2 : 1} of 2
      </div>
    {:else}
      <div class="phase complete">
        <Check aria-hidden="true" />2 devices in sync
      </div>
    {/if}
    <h1
      bind:this={heading}
      tabindex="-1"
      id="setup-heading"
      class:named={!!device}
    >
      {#if !vault}Keep passwords <span>on this device.</span>
      {:else if !account}Link a <span>second device.</span>
      {:else if !device}Finish on your <span>other device.</span>
      {:else}{vault}{/if}
    </h1>
    {#if !vault}
      <p class="lead">
        Your own cloud account syncs an encrypted copy across devices.
      </p>
    {:else if !account}
      <p class="lead">
        Connect your own cloud account to sync an encrypted copy of <strong>
          {vault}
        </strong>.
      </p>
    {:else if !device}
      <p class="lead">
        Open Nook on your other device and join with the same cloud account.
      </p>
    {/if}
  </div>
  <KeyringScene {vault} {account} {device} onActivate={openSetup} />
  <div class="setup-actions">
    {#if account}
      <div class="account-record">
        <Cloud aria-hidden="true" />
        <div class="record-text">
          <span>Sync account</span><strong>{account}</strong>
        </div>
        {#if !device}
          <Button
            variant="ghost"
            class="change-action rounded-none"
            aria-label="Change cloud account"
            onclick={(event) => openSetup("cloud", event.currentTarget)}
          >
            Change
          </Button>
        {/if}
      </div>
    {/if}
    {#if next}
      {@const action = actions[next]}
      <Button
        class="primary-action rounded-none"
        aria-haspopup="dialog"
        onclick={(event) => openSetup(next, event.currentTarget)}
      >
        <action.icon aria-hidden="true" strokeWidth={1.8} />{action.label}
      </Button>
    {/if}
  </div>
</main>

<SetupDialog
  bind:open={dialogOpen}
  kind={dialogKind}
  bind:value={draft}
  {vault}
  {account}
  onSave={save}
  onReturn={returnFocus}
/>
