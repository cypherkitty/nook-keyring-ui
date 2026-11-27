<script>
  import { Check, LockKeyhole } from "lucide-svelte";

  let { locations, stage, selectedId, onInspect } = $props();
  let tabs = [];
  let viewportWidth = $state(0);
  const vertical = $derived(viewportWidth >= 960);

  function navigate(event, index) {
    if (!vertical && (event.key === "ArrowDown" || event.key === "ArrowUp"))
      return;
    let next;
    switch (event.key) {
      case "ArrowDown":
      case "ArrowRight":
        next = (index + 1) % locations.length;
        break;
      case "ArrowUp":
      case "ArrowLeft":
        next = (index + locations.length - 1) % locations.length;
        break;
      case "Home":
        next = 0;
        break;
      case "End":
        next = locations.length - 1;
        break;
      default:
        return;
    }
    event.preventDefault();
    onInspect(locations[next].id);
    tabs[next].focus();
  }
</script>

<svelte:window bind:innerWidth={viewportWidth} />

<section class="keyring" aria-labelledby="keyring-heading">
  <div class="map-heading">
    <h2 id="keyring-heading">Your keyring</h2>
    <p id="map-hint">Select a location</p>
  </div>
  <div
    class="track"
    class:linked={stage === "linked"}
    role="tablist"
    aria-orientation={vertical ? "vertical" : "horizontal"}
    aria-labelledby="keyring-heading"
    aria-describedby="map-hint"
  >
    {#each locations as location, index}
      {#if index > 0}
        <span class="route" class:second={index === 2} aria-hidden="true">
          <i></i>
        </span>
      {/if}
      <button
        type="button"
        role="tab"
        id={"tab-" + location.id}
        aria-controls="location-panel"
        aria-selected={selectedId === location.id}
        tabindex={selectedId === location.id ? 0 : -1}
        class="station"
        class:active={selectedId === location.id}
        bind:this={tabs[index]}
        onclick={() => onInspect(location.id)}
        onkeydown={(event) => navigate(event, index)}
      >
        <span class="node-icon" aria-hidden="true">
          <location.icon size={19} strokeWidth={1.65} />
        </span>
        <span class="station-copy">
          <strong>{location.name}</strong>
          <small>
            <LockKeyhole size={12} aria-hidden="true" />Encrypted copy
          </small>
        </span>
        {#if stage === "linked" || (stage === "local" && location.id === "local")}
          <span class="registered">
            <Check size={13} strokeWidth={2.2} /><span class="sr-only">
              {stage === "linked" ? "Linked" : "Vault created"}
            </span>
          </span>
        {/if}
      </button>
    {/each}
  </div>
</section>

<style>
  .keyring {
    min-width: 0;
    padding: 25px 15px;
    background: #f8f8fa;
    border-right: 1px solid var(--line);
  }
  .map-heading {
    padding: 0 9px;
    margin-bottom: 22px;
  }
  h2 {
    margin: 0;
    font: 600 1.16rem/1.25 var(--display);
    letter-spacing: -0.045em;
  }
  .map-heading p {
    margin: 5px 0 0;
    color: var(--muted);
    font-size: 0.8rem;
    line-height: 1.4;
  }
  .track {
    display: grid;
    grid-template-columns: minmax(0, 1fr);
    grid-template-rows: auto 25px auto 25px auto;
    align-items: center;
  }
  .station {
    position: relative;
    display: flex;
    align-items: center;
    gap: 10px;
    min-width: 0;
    min-height: 66px;
    padding: 10px 9px;
    text-align: left;
    color: var(--ink);
    background: transparent;
    border: 1px solid transparent;
    border-radius: 8px;
    cursor: pointer;
  }
  .station:hover {
    background: #efeff4;
  }
  .station.active {
    background: #fff;
    border-color: #d8d6e2;
    box-shadow: 0 2px 4px #2119390d;
  }
  .node-icon {
    display: grid;
    place-items: center;
    flex: none;
    width: 32px;
    height: 32px;
    border-radius: 8px;
    color: #636370;
    background: #eeeef2;
  }
  .active .node-icon {
    color: var(--violet);
    background: #efebff;
  }
  .station-copy {
    min-width: 0;
    display: grid;
    gap: 5px;
  }
  .station-copy strong {
    font: 590 0.94rem/1.23 var(--display);
    letter-spacing: -0.03em;
    text-wrap: balance;
  }
  small {
    display: flex;
    align-items: center;
    gap: 4px;
    color: var(--muted);
    font: 400 0.75rem/1.35 var(--mono);
  }
  small :global(svg) {
    flex: none;
  }
  .registered {
    position: absolute;
    right: 4px;
    top: 4px;
    display: grid;
    place-items: center;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background: #eae4ff;
    color: var(--violet);
  }
  .route {
    position: relative;
    width: 1.5px;
    height: 17px;
    margin-left: 25px;
    color: #888597;
    background: currentColor;
  }
  .route::before,
  .route::after {
    content: "";
    position: absolute;
    left: 50%;
    width: 4px;
    height: 4px;
    border-top: 1.5px solid;
    border-right: 1.5px solid;
  }
  .route::before {
    top: 0;
    transform: translateX(-50%) rotate(-45deg);
  }
  .route::after {
    bottom: 0;
    transform: translateX(-50%) rotate(135deg);
  }
  .linked .route {
    color: var(--violet);
  }
  @media (prefers-reduced-motion: no-preference) {
    .linked .route i {
      position: absolute;
      top: 0;
      left: 50%;
      width: 4px;
      height: 4px;
      border-radius: 50%;
      opacity: 0;
      background: var(--violet);
      transform: translate(-50%, -50%);
      animation: down 0.65s ease-in-out;
    }
    .linked .route.second i {
      animation-delay: 0.65s;
    }
    @keyframes down {
      12%,
      88% {
        opacity: 1;
      }
      to {
        top: 100%;
        opacity: 0;
      }
    }
    @keyframes across {
      12%,
      88% {
        opacity: 1;
      }
      to {
        left: 100%;
        opacity: 0;
      }
    }
  }
  @media (max-width: 959px) {
    .keyring {
      padding: 16px;
      border-right: 0;
      border-bottom: 1px solid var(--line);
    }
    .map-heading {
      display: flex;
      align-items: baseline;
      justify-content: space-between;
      gap: 12px;
      padding: 0;
      margin-bottom: 11px;
    }
    .map-heading p {
      margin: 0;
    }
    .track {
      grid-template-rows: auto;
      grid-template-columns: minmax(0, 1fr) clamp(16px, 4vw, 42px) minmax(
          0,
          1.12fr
        ) clamp(16px, 4vw, 42px) minmax(0, 1fr);
      align-items: stretch;
    }
    .station {
      min-height: 57px;
      padding: 7px;
    }
    .route {
      width: calc(100% - 6px);
      height: 1.5px;
      margin: 0 3px;
      align-self: center;
    }
    .route::before,
    .route::after {
      left: auto;
      top: 50%;
      bottom: auto;
    }
    .route::before {
      left: 0;
      transform: translateY(-50%) rotate(-135deg);
    }
    .route::after {
      right: 0;
      transform: translateY(-50%) rotate(45deg);
    }
    .linked .route i {
      left: 0;
      top: 50%;
      animation-name: across;
    }
  }
  @media (max-width: 580px) {
    .keyring {
      padding: 14px 9px 10px;
    }
    .map-heading {
      padding-inline: 4px;
    }
    h2 {
      font-size: 1.02rem;
    }
    .map-heading p {
      font-size: 0.73rem;
    }
    .station {
      display: flex;
      flex-direction: column;
      justify-content: center;
      gap: 5px;
      text-align: center;
      padding: 6px 2px 7px;
    }
    .node-icon {
      width: 26px;
      height: 26px;
      border-radius: 6px;
    }
    .node-icon :global(svg) {
      width: 16px;
      height: 16px;
    }
    .station-copy {
      gap: 3px;
    }
    .station-copy strong {
      font-size: clamp(0.78rem, 2.9vw, 0.94rem);
    }
    small {
      justify-content: center;
      font-size: 0.69rem;
    }
    small :global(svg) {
      display: none;
    }
  }
</style>
