<script>
  import { Tabs } from "bits-ui";
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Phone from "@lucide/svelte/icons/smartphone";
  import Sync from "@lucide/svelte/icons/arrow-left-right";
  import Forward from "@lucide/svelte/icons/arrow-right";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Pencil from "@lucide/svelte/icons/pencil";
  import { Button } from "$lib/components/ui/button";
  import { Progress } from "$lib/components/ui/progress";
  import KeyringScene from "./KeyringScene.svelte";

  let { stage, vault, account, device, lastAttachment, selected = $bindable(), onEdit, onResume, children } = $props();

  const locations = $derived([
    {
      id: "vault", name: "This device", icon: Laptop, identity: vault,
      status: vault ? "Saved offline" : "Encrypted offline vault",
      current: stage === "ready",
      title: vault ? "Your local vault" : "Create your local vault",
    },
    {
      id: "cloud", name: "Your cloud account", icon: Cloud, identity: account,
      status: account ? "Encrypted copy saved" : "Encrypted sync copy",
      current: stage === "local",
      title: account ? "Your connected storage" : "Connect your cloud account",
    },
    {
      id: "device", name: device || "Second device", icon: Phone, identity: device,
      status: device ? "Saved offline" : account ? "Ready to link" : "Offline vault copy",
      current: stage === "cloud",
      title: device ? "Your vault is on both devices" : "Link your second device",
    },
  ]);
</script>

<Tabs.Root class="setup-workspace" bind:value={selected}>
  <Tabs.List class="progress-menu" aria-label="Keyring setup progress">
    {#each locations as location, index (location.id)}
      {@const state = location.identity ? "done" : location.current ? "current" : "waiting"}
      {@const detail = location.id === "device" ? vault : location.identity}
      <div class="checkpoint" role="presentation" data-location={location.id}
        data-status={state} data-selected={selected === location.id}>
        <Tabs.Trigger value={location.id} class="checkpoint-button"
          aria-current={location.current ? "step" : undefined}>
          <span class="checkpoint-label">
            <location.icon class="location-icon" strokeWidth={1.7} aria-hidden="true" />
            <span class:named-device={location.id === "device" && !!device} title={location.name}>{location.name}</span>
            {#if location.identity}<Check class="saved-check" strokeWidth={2.7} aria-hidden="true" />{/if}
          </span>
          <span class="checkpoint-detail">
            <span class="sr-only">{state === "done" ? "Complete" : location.current ? "Current" : "Waiting"}. </span>
            <span>{location.status}</span>
            {#if location.identity}
              <span class="checkpoint-identity" title={detail}> · {detail}</span>
            {/if}
          </span>
        </Tabs.Trigger>
        <Progress class="checkpoint-meter rounded-none" value={location.identity ? 1 : 0} max={1}
          aria-hidden="true" />
        {#if index > 0}
          <span class="sync-bridge" class:connected={!!location.identity} aria-hidden="true"><Sync /></span>
        {/if}
      </div>
    {/each}
  </Tabs.List>

  <div class="checkpoint-body">
    {#each locations as location (location.id)}
      <Tabs.Content value={location.id} class="checkpoint-panel" tabindex={-1}>
        <div class="panel-intro">
          <h2 id={"location-" + location.id} tabindex="-1">{location.title}</h2>
          {#if location.current && location.id === "cloud"}
            <p>Your storage syncs the encrypted vault to your next device.</p>
          {:else if location.current && location.id === "device"}
            <p id="join-account">Open Nook on that device with <strong>{account}</strong>.</p>
          {:else if location.id === "cloud" && account}
            <p class="connected-account"><Lock aria-hidden="true" />{account}</p>
          {:else if !location.current && !location.identity}
            <p>{location.id === "cloud" ? "Your storage will hold an encrypted copy of your vault." : "This device will keep an offline copy from your cloud account."}</p>
          {/if}
        </div>
        {#if location.current}
          {@render children()}
        {:else if location.identity}
          {#if location.id === "cloud"}
            {#if !device}
              <Button variant="outline" class="secondary-action rounded-none" aria-haspopup="dialog"
                onclick={(event) => onEdit(event.currentTarget)}><Pencil aria-hidden="true" />Change cloud account</Button>
            {/if}
          {:else}
            <a class="vault-link" href="#vault" title={vault}>
              <Lock aria-hidden="true" /><span>{vault}</span><Forward aria-hidden="true" />
            </a>
          {/if}
        {:else}
          <Button variant="outline" class="secondary-action rounded-none" onclick={onResume}>
            {vault ? "Connect your cloud first" : "Create your vault first"}<Forward aria-hidden="true" />
          </Button>
        {/if}
      </Tabs.Content>
    {/each}
    <div class="ring-view"><KeyringScene {stage} attach={lastAttachment === "vault"} /></div>
  </div>
</Tabs.Root>
