<script>
  import { tick } from "svelte";
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import KeyRound from "@lucide/svelte/icons/key-round";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Restart from "@lucide/svelte/icons/rotate-ccw";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Card from "$lib/components/ui/card";
  import KeyringScene from "./KeyringScene.svelte";
  import VaultMilestones from "./VaultMilestones.svelte";
  import SetupDialog from "./SetupDialog.svelte";

  // Only the labels for this preview session are kept in memory.
  let vault = $state("");
  let account = $state("");
  let device = $state("");
  let vaultName = $state("Personal vault");
  let email = $state("you@example.com");
  let dialogOpen = $state(false);
  let dialogKind = $state("device");
  let dialogValue = $state("");
  let opener;
  let heading;

  const stage = $derived(
    !vault ? "ready" : !account ? "local" : !device ? "cloud" : "linked",
  );
  const members = $derived(Number(!!vault) + Number(!!device));
  const instructions = {
    ready: {
      icon: Laptop,
      step: "Step 1 of 2",
      title: "Create your local vault",
      detail: "The devices you link to this vault form your keyring.",
    },
    local: {
      icon: Check,
      step: "Step 2 of 2 · Link another device",
      title: "Your local vault is ready",
      detail: "Connect your own cloud account to sync an encrypted copy.",
    },
    cloud: {
      icon: Cloud,
      step: "Step 2 of 2 · Link another device",
      title: "Your cloud copy is ready",
      detail: "Join from your second device with the same cloud account.",
    },
    linked: {
      icon: Check,
      step: "Setup complete",
      title: "Your devices are in sync",
    },
  };
  const current = $derived(instructions[stage]);

  async function showResult() {
    await tick();
    if (!heading) return;
    heading.focus({ preventScroll: true });
    const bounds = heading.getBoundingClientRect();
    if (bounds.top < 0 || bounds.bottom > window.innerHeight) {
      heading.scrollIntoView({ block: "nearest", behavior: "instant" });
    }
  }

  function createVault(event) {
    event.preventDefault();
    const name = vaultName.trim();
    if (stage !== "ready" || !name) return;
    vault = name;
    showResult();
  }

  function connectAccount(event) {
    event.preventDefault();
    if (stage !== "local") return;
    account = email.trim();
    showResult();
  }

  function openSetup(kind, trigger) {
    dialogKind = kind;
    dialogValue = kind === "device" ? "My phone" : account;
    opener = trigger;
    dialogOpen = true;
  }

  function closeSetup(value) {
    if (value === null) {
      opener?.focus();
      return;
    }
    if (dialogKind === "device") device = value;
    else account = value;
    showResult();
  }

  function restart() {
    vault = "";
    account = "";
    device = "";
    vaultName = "Personal vault";
    email = "you@example.com";
    showResult();
  }
</script>

<header class="masthead">
  <div class="header-inner">
    <div class="brand">
      <span class="wordmark">
        <img src={import.meta.env.BASE_URL + "nook.svg"} alt="" width="23" height="23" />nook
      </span>
      <span class="brand-purpose">Local-first password manager</span>
    </div>
    {#if vault}
      <Button
        variant="ghost"
        class="restart rounded-none"
        aria-label="Restart preview"
        onclick={restart}
      >
        <Restart aria-hidden="true" /><span>
          Restart<span class="preview-word">{" preview"}</span>
        </span>
      </Button>
    {:else}
      <span class="preview-label">Setup preview</span>
    {/if}
  </div>
</header>

<main class="workbench" data-stage={stage} aria-labelledby="vault-heading">
  <div class="hero">
    <div class="hero-copy">
      <h1 id="vault-heading" title={vault || undefined}>
        {vault || "One password vault for your devices"}
      </h1>
      {#if stage === "ready"}
        <dl class="vault-locations">
          <div>
            <dt><Laptop aria-hidden="true" />On each device</dt>
            <dd>Open your encrypted vault even when you’re offline.</dd>
          </div>
          <div>
            <dt><Cloud aria-hidden="true" />In your own cloud account</dt>
            <dd>An encrypted copy keeps your linked devices in sync.</dd>
          </div>
        </dl>
      {:else}
        <p>Linked devices sync your encrypted vault through your own cloud account.</p>
        <div class="member-count">
          <KeyRound aria-hidden="true" />{members}
          {members === 1 ? "device" : "devices"} on your keyring
        </div>
      {/if}
    </div>
    <KeyringScene {stage} />
  </div>

  <Card.Root
    class="setup-panel rounded-none"
    role="region"
    aria-label="Keyring setup progress"
  >
    <div class="readiness">
      <div class="readiness-message">
        <span class="summary-icon" aria-hidden="true">
          <current.icon strokeWidth={1.7} />
        </span>
        <div class="summary-copy">
          <span class="chapter" id="setup-step">{current.step}</span>
          <h2
            id="setup-task"
            bind:this={heading}
            tabindex="-1"
            aria-describedby={current.detail
              ? "setup-step setup-reason"
              : "setup-step"}
          >
            {current.title}
          </h2>
          {#if current.detail}<p id="setup-reason">{current.detail}</p>{/if}
        </div>
      </div>
      {#if stage === "ready"}
        <form
          class="action-form"
          aria-label="Create a vault on this device"
          onsubmit={createVault}
        >
          <div class="field">
            <label for="vault-name">Vault name</label>
            <Input
              id="vault-name"
              class="setup-input rounded-none"
              bind:value={vaultName}
              pattern={".*\\S.*"}
              title="Enter a vault name"
              required
              autocomplete="off"
            />
          </div>
          <Button type="submit" class="action rounded-none">
            Create vault
          </Button>
        </form>
      {:else if stage === "local"}
        <form
          class="action-form"
          aria-label="Connect your own cloud account"
          onsubmit={connectAccount}
        >
          <div class="field">
            <label for="cloud-email">Cloud account email</label>
            <Input
              id="cloud-email"
              class="setup-input rounded-none"
              type="email"
              bind:value={email}
              required
              placeholder="you@example.com"
              autocomplete="off"
              autocapitalize="none"
              spellcheck={false}
            />
          </div>
          <Button
            type="submit"
            class="action rounded-none"
            aria-label="Connect account"
          >
            <span>Connect<span class="account-word">{" account"}</span></span>
          </Button>
        </form>
      {:else if stage === "cloud"}
        <Button
          class="action peer-action rounded-none"
          aria-haspopup="dialog"
          onclick={(event) => openSetup("device", event.currentTarget)}
        >
          Link second device
        </Button>
      {/if}
    </div>
    <VaultMilestones
      {stage}
      {vault}
      {account}
      {device}
      onEdit={(trigger) => openSetup("cloud", trigger)}
    />
  </Card.Root>
</main>

<SetupDialog
  bind:open={dialogOpen}
  kind={dialogKind}
  bind:value={dialogValue}
  {vault}
  {account}
  onReturn={closeSetup}
/>
