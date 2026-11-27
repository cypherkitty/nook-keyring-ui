<script>
  import { tick } from "svelte";
  import {
    Check,
    Cloud,
    Laptop,
    Link2,
    LockKeyhole,
    Plus,
    RotateCcw,
    Smartphone,
  } from "lucide-svelte";
  import KeyringMap from "./KeyringMap.svelte";

  const locations = [
    {
      id: "local",
      name: "This device",
      icon: Laptop,
      image: "/keyring/local.webp",
      alt: "An exploded metal vault with a keyhole plate above its illuminated glass core.",
      title: ["Your local", "vault."],
      description:
        "Keep your passwords encrypted on this device. Your own cloud account syncs changes to your other device.",
    },
    {
      id: "cloud",
      name: "Your cloud account",
      icon: Cloud,
      image: "/keyring/cloud.webp",
      alt: "A personal cloud-shaped storage module with an account symbol and the same vault keyhole.",
      title: ["Your own", "cloud account."],
      description:
        "Your cloud account stores an encrypted vault copy. Password changes pass through it between your devices.",
    },
    {
      id: "other",
      name: "Other device",
      icon: Smartphone,
      image: "/keyring/other.webp",
      alt: "A phone holding the same illuminated keyhole vault in its screen.",
      title: ["Your other", "device."],
      description:
        "A second device keeps its own encrypted copy. It uses the same cloud account to sync password changes.",
    },
  ];

  let stage = $state("empty");
  let selectedId = $state("local");
  let heading = $state();
  const selected = $derived(
    locations.find((location) => location.id === selectedId),
  );
  const title = $derived.by(() => {
    if (selectedId === "local" && stage === "empty")
      return ["Create your", "local vault."];
    if (selectedId === "cloud" && stage === "local")
      return ["Link your", "next device."];
    if (selectedId === "other" && stage === "linked")
      return ["Your devices", "are linked."];
    return selected.title;
  });
  const description = $derived.by(() => {
    if (selectedId === "cloud" && stage === "local")
      return "Use your own cloud account on both devices. It holds an encrypted copy and keeps your passwords in sync.";
    if (selectedId === "other" && stage === "linked")
      return "Both devices now keep an encrypted vault. Change a password on either one and it syncs through your cloud account.";
    return selected.description;
  });

  function inspect(id) {
    selectedId = id;
  }

  async function navigateTo(id) {
    inspect(id);
    await tick();
    heading.focus({ preventScroll: true });
  }

  function createVault() {
    stage = "local";
    navigateTo("cloud");
  }
  function linkDevice() {
    stage = "linked";
    navigateTo("other");
  }
  function reset() {
    stage = "empty";
    navigateTo("local");
  }
</script>

<header class="masthead">
  <div class="identity">
    <div class="brand" aria-label="Nook">
      <img src="/nook.svg" alt="" />nook<span>.</span>
    </div>
    <span class="descriptor">Local-first password manager</span>
  </div>
  {#if stage === "empty" && selectedId === "local"}
    <small class="preview-label">Interactive preview</small>
  {:else}
    <button class="reset" onclick={reset}>
      <RotateCcw size={14} aria-hidden="true" />Reset preview
    </button>
  {/if}
</header>

<main>
  <div class="workspace">
    <KeyringMap {locations} {stage} {selectedId} onInspect={inspect} />

    <div
      class="inspector"
      id="location-panel"
      role="tabpanel"
      aria-labelledby={"tab-" + selectedId}
    >
      <div class="panel-bar">
        <div class="context">
          <selected.icon
            size={17}
            strokeWidth={1.6}
            aria-hidden="true"
          />{selected.name}
        </div>
        <span class="annotation">
          <LockKeyhole size={13} aria-hidden="true" />Encrypted vault
        </span>
      </div>
      <div class="artifact">
        {#each locations as location}
          <img
            class:visible={selectedId === location.id}
            class="render"
            src={location.image}
            alt={selectedId === location.id ? location.alt : ""}
            aria-hidden={selectedId !== location.id}
            width="1280"
            height="960"
            decoding="async"
          />
        {/each}
      </div>

      <div class="detail">
        <h1 tabindex="-1" bind:this={heading}>
          {title[0]} <em>{title[1]}</em>
        </h1>
        <p>{description}</p>
        <div class="action">
          {#if stage === "empty"}
            {#if selectedId === "local"}
              <button class="primary" onclick={createVault}>
                <Plus size={18} />Create vault
              </button>
            {:else}
              <button class="primary" onclick={() => navigateTo("local")}>
                <Laptop size={17} />Start on this device
              </button>
            {/if}
          {:else if stage === "local"}
            {#if selectedId === "local"}
              <button class="primary" onclick={() => navigateTo("cloud")}>
                <Link2 size={17} />Add another device
              </button>
            {:else}
              <button class="primary" onclick={linkDevice}>
                <Link2 size={17} />Link device
              </button>
            {/if}
          {:else}
            <span class="synced">
              <Check size={17} aria-hidden="true" />Devices in sync
            </span>
          {/if}
        </div>
      </div>
    </div>
  </div>
</main>
