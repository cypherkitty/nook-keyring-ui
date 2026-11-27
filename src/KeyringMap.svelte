<script>
  import { Check, LockKeyhole } from "lucide-svelte";

  let { locations, stage, selectedId, onInspect } = $props();
  let tabs = [];

  function navigate(event, index) {
    let next;
    switch (event.key) {
      case "ArrowRight":
        next = (index + 1) % locations.length;
        break;
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

<section class="keyring" aria-labelledby="keyring-heading">
  <div class="map-heading">
    <h2 id="keyring-heading">Your keyring</h2>
    <p id="map-hint">Select a location</p>
  </div>
  <div
    class="track"
    class:linked={stage === "linked"}
    role="tablist"
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
        <span class="thumbnail" aria-hidden="true">
          <img src={location.image} alt="" width="80" height="60" />
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
              Linked
            </span>
          </span>
        {/if}
      </button>
    {/each}
  </div>
</section>

<style>
  .keyring {
    order: 2;
    padding-top: 26px;
    border-top: 1px solid var(--rule);
  }
  .map-heading {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 12px;
    margin-bottom: 15px;
  }
  h2 {
    margin: 0;
    font: 550 1.2rem/1.25 var(--display);
    letter-spacing: -0.04em;
  }
  .map-heading p {
    margin: 0;
    font: 400 0.77rem/1.4 var(--mono);
    color: var(--muted);
  }
  .track {
    display: grid;
    grid-template-columns:
      minmax(0, 1fr) clamp(20px, 5vw, 72px) minmax(0, 1.1fr)
      clamp(20px, 5vw, 72px) minmax(0, 1fr);
    align-items: center;
  }
  .station {
    position: relative;
    display: flex;
    align-items: center;
    gap: clamp(9px, 1.2vw, 18px);
    min-width: 0;
    min-height: 85px;
    height: 100%;
    padding: 9px clamp(10px, 1vw, 17px);
    border: 1px solid var(--rule);
    border-radius: 10px;
    background: #fffdf9;
    text-align: left;
    color: var(--ink);
    cursor: pointer;
    transition:
      background 0.18s,
      border-color 0.18s;
  }
  .station:hover {
    border-color: #b7967f;
    background: #f8eee5;
  }
  .station.active {
    border-color: #ae785b;
    background: linear-gradient(115deg, #f7e5d7, #fbf0e6);
    box-shadow: inset 0 -2px 0 var(--accent);
  }
  .thumbnail {
    display: block;
    flex: 0 0 auto;
    width: clamp(45px, 5.2vw, 75px);
    aspect-ratio: 1.15;
    overflow: hidden;
    border-radius: 5px;
    background: #201913;
  }
  .thumbnail img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
    filter: var(--hardware-finish);
  }
  .station-copy {
    min-width: 0;
    display: grid;
    gap: 6px;
  }
  .station-copy strong {
    font: 550 clamp(0.93rem, 1.35vw, 1.12rem)/1.18 var(--display);
    letter-spacing: -0.03em;
    text-wrap: balance;
  }
  small {
    display: flex;
    align-items: center;
    gap: 5px;
    font: 400 0.75rem/1.35 var(--mono);
    color: var(--muted);
  }
  small :global(svg) {
    flex: none;
  }
  .registered {
    position: absolute;
    right: 6px;
    top: 6px;
    display: grid;
    place-items: center;
    width: 17px;
    height: 17px;
    border-radius: 50%;
    background: #eed7c7;
    color: var(--accent);
  }
  .route {
    position: relative;
    height: 1.5px;
    margin: 0 7px;
    background: #9e7c66;
    color: #8d6b55;
  }
  .route::before,
  .route::after {
    content: "";
    position: absolute;
    top: 50%;
    width: 6px;
    height: 6px;
    border-top: 1.5px solid;
    border-right: 1.5px solid;
  }
  .route::before {
    left: 0;
    transform: translateY(-50%) rotate(-135deg);
  }
  .route::after {
    right: 0;
    transform: translateY(-50%) rotate(45deg);
  }
  .linked .route {
    background: var(--accent);
  }
  @media (prefers-reduced-motion: no-preference) {
    .linked .route i {
      position: absolute;
      left: 0;
      top: -2px;
      width: 5px;
      height: 5px;
      border-radius: 50%;
      opacity: 0;
      background: #b15229;
      box-shadow: 0 0 8px #d89264;
      animation: travel 0.65s ease-in-out;
    }
    .linked .route.second i {
      animation-delay: 0.65s;
    }
    @keyframes travel {
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
  @media (max-width: 900px) and (min-width: 681px) {
    .track {
      grid-template-columns: minmax(0, 1fr) 23px minmax(0, 1.13fr) 23px minmax(
          0,
          1fr
        );
    }
    .station {
      gap: 8px;
      padding-inline: 8px;
    }
    .route {
      margin-inline: 4px;
    }
    small {
      font-size: 0.69rem;
    }
  }
  @media (max-width: 680px) {
    .keyring {
      order: 0;
      border: 0;
      padding-top: 0;
    }
    .map-heading {
      margin-bottom: 10px;
    }
    h2 {
      font-size: 1.05rem;
    }
    .map-heading p {
      font-size: 0.69rem;
    }
    .track {
      grid-template-columns: minmax(0, 1fr) 17px minmax(0, 1.12fr) 17px minmax(
          0,
          1fr
        );
      align-items: stretch;
    }
    .station {
      display: grid;
      grid-template-rows: 35px 1fr;
      justify-items: center;
      gap: 4px;
      min-height: 0;
      padding: 7px 3px 9px;
      text-align: center;
      border-radius: 7px;
    }
    .thumbnail {
      width: 47px;
      height: 35px;
      border-radius: 3px;
    }
    .station-copy {
      align-self: center;
      gap: 3px;
    }
    .station-copy strong {
      font-size: clamp(0.78rem, 2.85vw, 0.98rem);
      line-height: 1.18;
    }
    small {
      justify-content: center;
      gap: 2px;
      font-size: clamp(0.65rem, 2.2vw, 0.74rem);
    }
    small :global(svg) {
      display: none;
    }
    .route {
      align-self: center;
      margin-inline: 3px;
    }
    .route::before,
    .route::after {
      width: 3px;
      height: 3px;
    }
    .registered {
      width: 14px;
      height: 14px;
      top: 3px;
      right: 3px;
    }
  }
</style>
