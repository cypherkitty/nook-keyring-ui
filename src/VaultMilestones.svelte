<script>
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Pencil from "@lucide/svelte/icons/pencil";
  import Phone from "@lucide/svelte/icons/smartphone";
  import { Button } from "$lib/components/ui/button";

  let { stage, vault, account, device, lastAttachment, onEdit, children } = $props();

  const locations = $derived([
    {
      id: "vault", name: "This device", icon: Laptop, role: vault ? "Saved offline" : "Encrypted offline vault",
      attached: !!vault, current: stage === "ready",
      phase: { number: 1, name: vault ? "Vault created" : "Create a local vault", done: !!vault, current: !vault },
    },
    {
      id: "cloud", name: "Your cloud account", icon: Cloud, role: account ? "Encrypted copy saved" : "Encrypted sync copy",
      attached: !!account, current: stage === "local",
      phase: { number: 2, name: device ? "Second device linked" : "Link another device", done: !!device, current: !!vault && !device },
    },
    {
      id: "device", name: device || "Second device", icon: Phone, role: device ? "Saved offline" : "Offline vault copy",
      attached: !!device, current: stage === "cloud",
    },
  ]);
</script>

<ol class="keyring-path" role="list" aria-label="Your devices sync an encrypted vault through your own cloud account">
  {#each locations as location, i (location.id)}
    {@const next = locations[i + 1]}
    <li class="path-stop" data-location={location.id}
      data-status={location.attached ? "done" : location.current ? "current" : "planned"}>
      {#if location.phase}
        <div class="phase-heading" id={"phase-" + location.phase.number} class:complete={location.phase.done} aria-current={location.phase.current ? "step" : undefined}>
          <span class="phase-mark" aria-hidden="true">{#if location.phase.done}<Check />{:else}{location.phase.number}{/if}</span>
          <span class="sr-only">Step {location.phase.number} of 2. </span><span>{location.phase.name}</span>
        </div>
      {/if}

      <div class="path-port" aria-hidden="true">
        <div class="port-symbol">
          <location.icon class="port-icon" strokeWidth={1.5} />
          {#if location.id === "cloud"}<Lock class="cloud-lock" strokeWidth={1.8} />{/if}
          {#if location.attached}<span class="port-check"><Check strokeWidth={3} /></span>{/if}
        </div>
        {#if next}
          <span class="sync-link" data-connected={next.attached} data-next={next.current}>
            <span class="link-track"></span><span class="link-fill"></span>
            {#if next.attached && lastAttachment === next.id}
              <span class="copy-in-transit"><Lock strokeWidth={2} /></span>
            {/if}
          </span>
        {/if}
      </div>

      <div class="stop-content">
        <h2 id={"location-" + location.id} tabindex="-1" aria-describedby={"phase-" + (i === 0 ? 1 : 2) + " role-" + location.id} title={location.id === "device" && device ? device : undefined}>{location.name}</h2>
        <p class="stop-role" id={"role-" + location.id}>{location.role}</p>
        {#if location.attached}
          {#if location.id === "cloud"}
            {#if device}
              <span class="stop-value" title={account}>{account}</span>
            {:else}
              <Button variant="link" class="edit-account rounded-none" aria-label="Change cloud account"
                aria-describedby="sync-account-identity" aria-haspopup="dialog" title={account} onclick={(event) => onEdit(event.currentTarget)}>
                <span id="sync-account-identity">{account}</span><Pencil aria-hidden="true" />
              </Button>
            {/if}
          {:else}
            <a class="vault-link" href="#vault" title={vault}><Lock aria-hidden="true" /><span>{vault}</span></a>
          {/if}
        {:else if location.current}
          {#if location.id === "device"}
            <p class="join-account" id="join-account">Open Nook on that device with <strong>{account}</strong>.</p>
          {/if}
          <div class="stop-action">{@render children()}</div>
        {/if}
      </div>
    </li>
  {/each}
</ol>
