<script>
  import { tick } from "svelte";
  import Check from "@lucide/svelte/icons/check";
  import Restart from "@lucide/svelte/icons/rotate-ccw";
  import { Button } from "$lib/components/ui/button";
  import { Input } from "$lib/components/ui/input";
  import * as Card from "$lib/components/ui/card";
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
  let workbench;

  const stage = $derived(
    !vault ? "ready" : !account ? "local" : !device ? "cloud" : "linked",
  );
  const members = $derived(Number(!!vault) + Number(!!device));

  async function showResult() {
    await tick();
    const heading = workbench?.querySelector(
      stage === "linked" ? "#vault-heading" : '[data-status="current"] h2',
    );
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

<main bind:this={workbench} class="workbench" data-stage={stage} aria-labelledby="vault-heading">
  <div class="bench-heading">
    <div class="bench-title">
      <h1
        id="vault-heading"
        tabindex="-1"
        title={vault || undefined}
        aria-describedby={vault ? "member-count" : undefined}
      >
        {#if vault}{vault}{:else}Save passwords here. <span>Sync through your cloud.</span>{/if}
      </h1>
      {#if vault}
        <p id="member-count">{members === 1 ? "1 device on your keyring" : "2 devices in sync"}</p>
      {/if}
    </div>
    <ol class="setup-steps" role="list" aria-label="Setup progress">
      <li class:complete={!!vault} aria-current={!vault ? "step" : undefined}>
        <span class="step-mark" aria-hidden="true">{#if vault}<Check />{:else}1{/if}</span>
        <span class="sr-only">Step 1 of 2. </span>{vault ? "Vault created" : "Create vault"}
      </li>
      <li class:complete={!!device} aria-current={vault && !device ? "step" : undefined}>
        <span class="step-mark" aria-hidden="true">{#if device}<Check />{:else}2{/if}</span>
        <span class="sr-only">Step 2 of 2. </span>{device ? "Device linked" : "Link device"}
      </li>
    </ol>
  </div>

  <Card.Root
    class="setup-panel rounded-none"
    role="region"
    aria-label="Keyring setup progress"
  >
    <VaultMilestones
      {stage}
      {vault}
      {account}
      {device}
      onEdit={(trigger) => openSetup("cloud", trigger)}
    >
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
          class="action rounded-none"
          aria-haspopup="dialog"
          onclick={(event) => openSetup("device", event.currentTarget)}
        >
          Link second device
        </Button>
      {/if}
    </VaultMilestones>
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
