<script>
  import Check from "@lucide/svelte/icons/check";
  import Cloud from "@lucide/svelte/icons/cloud";
  import Laptop from "@lucide/svelte/icons/laptop";
  import Lock from "@lucide/svelte/icons/lock-keyhole";
  import Phone from "@lucide/svelte/icons/smartphone";
  import UserRound from "@lucide/svelte/icons/user-round";
  import { Button } from "$lib/components/ui/button";

  let { vault, account, device, stage, onEdit, controls } = $props();

  const frames = [
    { stage: "ready", src: "/keyring/ready.webp" },
    { stage: "local", src: "/keyring/local-vault.webp" },
    { stage: "cloud", src: "/keyring/cloud-copy.webp" },
    { stage: "linked", src: "/keyring/keyring-original.png" },
  ];
  const stops = $derived([
    {
      id: "vault",
      label: "This device",
      detail: vault || "Local vault",
      saved: !!vault,
      active: stage === "ready",
      icon: Laptop,
    },
    {
      id: "cloud",
      label: "Your cloud account",
      detail: account || "Encrypted sync copy",
      saved: !!account,
      active: stage === "local",
      icon: Cloud,
    },
    {
      id: "device",
      label: device || "Second device",
      detail: device ? "Encrypted local copy" : "Local copy",
      saved: !!device,
      active: stage === "cloud",
      icon: Phone,
    },
  ]);
  const members = $derived(Number(!!vault) + Number(!!device));
</script>

<figure class="assembly" aria-label="Your keyring and its vault copies">
  <div class="photograph">
    <div
      class="photo-stack"
      role="img"
      aria-label={stage === "ready"
        ? "An empty steel ring with the first orange device tag waiting beside it."
        : stage === "local"
          ? "The orange tag is now attached to the ring. Your first device holds the encrypted vault."
          : stage === "cloud"
            ? "A silver tag has joined the orange tag. Your own cloud holds an encrypted sync copy."
            : "The complete keyring. The two device tags and silver cloud copy are together on the ring."}
    >
      {#each frames as frame (frame.stage)}
        <picture
          class="frame"
          class:shown={stage === frame.stage}
          data-frame={frame.stage}
          aria-hidden="true"
        >
          {#if frame.stage === "linked"}<source
              media="(max-width: 680px)"
              srcset="/keyring/vault-ring.webp"
            />{/if}
          <img
            src={frame.src}
            width="1448"
            height="1086"
            alt=""
            fetchpriority={frame.stage === "ready"
              ? "high"
              : frame.stage === "linked"
                ? "low"
                : "auto"}
            draggable="false"
          />
        </picture>
      {/each}
      {#if stage === "local"}
        <div class="first-attachment" aria-hidden="true">
          <!-- Separate the amber acrylic from the neutral studio backdrop while the tag moves. -->
          <svg width="0" height="0" focusable="false">
            <defs>
              <filter id="loose-tag" color-interpolation-filters="sRGB">
                <feColorMatrix
                  type="matrix"
                  values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  8 0 -8 0 -.09"
                />
              </filter>
              <filter id="empty-studio" color-interpolation-filters="sRGB">
                <feColorMatrix
                  type="matrix"
                  values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  -8 0 8 0 1.09"
                />
              </filter>
            </defs>
          </svg>
          <i class="still-ring"></i><i class="travelling-tag"></i>
        </div>
      {/if}
    </div>
    <div class="ring-caption">
      <span class="tag-meter" aria-hidden="true">
        <i class:filled={!!vault}></i><i class:filled={!!device}></i>
      </span>
      <span>
        {members}
        {members === 1 ? "device" : "devices"} on your keyring
      </span>
    </div>

    <span class="leader local-leader" class:loose={!vault} aria-hidden="true">
      <svg viewBox="0 0 100 100" preserveAspectRatio="none">
        <path d="M100 0 L89 30 H0 V100" />
      </svg>
    </span>
    {#if account}
      <span class="leader cloud-leader" aria-hidden="true">
        <svg viewBox="0 0 100 100" preserveAspectRatio="none">
          <path d="M100 0 L0 52 V100" />
        </svg>
      </span>
    {/if}
    {#if device}
      <span class="leader peer-leader" aria-hidden="true">
        <svg viewBox="0 0 100 100" preserveAspectRatio="none">
          <path d="M0 0 L16 32 H100 V100" />
        </svg>
      </span>
    {/if}
  </div>

  <div class="network">
    {#each [account, device] as destination, index}
      <span
        class="wire"
        class:second={index === 1}
        class:live={!!destination}
        aria-hidden="true"
      >
        {#if destination}{#key destination}<span class="packet">
              <Lock />
            </span>{/key}{/if}
        {#if stage === "linked"}<span class="packet return-copy">
            <Lock />
          </span>{/if}
      </span>
    {/each}
    <ol
      class="stops"
      role="list"
      aria-label="Encrypted vault copies sync in both directions through your own cloud account"
    >
      {#each stops as stop (stop.id)}
        <li
          data-stop={stop.id}
          class:active={stop.active}
          class:saved={stop.saved}
          aria-current={stop.active ? "location" : undefined}
        >
          <div class="port" aria-hidden="true">
            <stop.icon strokeWidth={1.65} />
            {#if stop.id === "cloud"}<span class="owner">
                <UserRound strokeWidth={1.9} />
              </span>{/if}
            {#if stop.saved}<i><Check strokeWidth={3} /></i>{/if}
          </div>
          <strong class="place">{stop.label}</strong>
          <span class="identity" title={stop.detail}>
            {#if stop.saved}<Lock aria-hidden="true" />{/if}
            <span>{stop.detail}</span>
          </span>
          {#if stop.id === "cloud" && account && !device}
            <Button
              variant="link"
              class="change-action rounded-none"
              aria-label="Change cloud account"
              aria-haspopup="dialog"
              onclick={(event) => onEdit(event.currentTarget)}
            >
              Change account
            </Button>
          {/if}
        </li>
      {/each}
    </ol>
  </div>

  <div class="instrument" class:finished={stage === "linked"}>
    <span class="tool-trace" aria-hidden="true">
      <svg viewBox="0 0 100 100" preserveAspectRatio="none">
        <path d="M0 100 L18 0 H100" />
      </svg>
    </span>
    <div class="dock" data-at={stage}>
      {#if stage === "linked"}
        <div class="plate-heading">
          <Check aria-hidden="true" /> Device linked
        </div>
        <strong class="result-device">{device}</strong>
        <span class="result-vault"><Lock aria-hidden="true" />{vault}</span>
      {:else}
        <div class="plate-heading">
          {#if stage === "ready"}<Laptop aria-hidden="true" />This device
          {:else if stage === "local"}<Cloud aria-hidden="true" />Your cloud
            account
          {:else}<Phone aria-hidden="true" />Second device{/if}
        </div>
        {@render controls()}
      {/if}
    </div>
  </div>
</figure>
