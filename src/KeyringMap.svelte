<script>
  import { LockKeyhole, UserRound } from "lucide-svelte";
  let { copies, transfer, actionNode, action } = $props();
  const places = [
    { name: "This device", kind: "laptop", planned: "Local vault" },
    {
      name: "Your cloud account",
      kind: "cloud",
      planned: "Encrypted sync copy",
    },
    { name: "Other device", kind: "phone", planned: "Local vault" },
  ];
</script>

{#snippet vault()}
  <span class="vault" aria-hidden="true">
    <span class="vault-face"><LockKeyhole strokeWidth={1.7} /><i></i></span>
  </span>
{/snippet}

<div class="map" style={"--action-column: " + (actionNode * 2 + 1)}>
  {#each places as place, index}
    {#if index > 0}
      <div
        class="connection"
        class:connected={copies[index - 1] > 0 && copies[index] > 0}
        aria-hidden="true"
      >
        {#if transfer && Math.min(transfer.from, transfer.to) === index - 1}
          <i class:back={transfer.from > transfer.to}></i>
        {/if}
      </div>
    {/if}
    <div class="place" class:stored={copies[index] > 0}>
      <div class="figure" aria-hidden="true">
        {#if place.kind === "laptop"}
          <div class="laptop">
            <div class="lid"><div class="screen">{@render vault()}</div></div>
            <div class="base"></div>
          </div>
        {:else if place.kind === "cloud"}
          <div class="cloud">
            <svg class="cloud-drawing" viewBox="0 0 192 144" aria-hidden="true">
              <path
                d="M32 121h117c19 0 34-14 34-32 0-17-13-31-30-32-4-23-22-40-46-40-20 0-38 12-45 30a31 31 0 0 0-42 27C11 79 6 86 6 96c0 14 12 25 26 25Z"
              />
            </svg>
            {@render vault()}
            <span class="owner"><UserRound strokeWidth={1.6} /></span>
          </div>
        {:else}
          <div class="phone"><div class="screen">{@render vault()}</div></div>
        {/if}
      </div>
      <h3>{place.name}</h3>
      <span class="copy-status">
        {#if copies[index]}<span class="copy-mark" aria-hidden="true"
          ></span>Vault v{copies[index]}{:else}{place.planned}{/if}
      </span>
    </div>
  {/each}
  <div class="map-action">{@render action()}</div>
</div>

<style>
  .map {
    --figure-height: clamp(140px, 16vw, 202px);
    position: relative;
    isolation: isolate;
    display: grid;
    grid-auto-flow: column;
    grid-template-columns:
      minmax(0, 1fr) minmax(18px, 0.31fr) minmax(0, 1fr)
      minmax(18px, 0.31fr) minmax(0, 1fr);
    grid-template-rows: var(--figure-height) auto auto auto;
    align-items: start;
    padding: clamp(26px, 3.7vw, 50px) clamp(20px, 4.2vw, 58px)
      clamp(26px, 2.6vw, 38px);
    background: #fbfcfd;
  }
  .map::before {
    content: "";
    position: absolute;
    inset: 0;
    z-index: -1;
    pointer-events: none;
    background-image: radial-gradient(#98a6b5 0.85px, transparent 0.95px);
    background-size: 16px 16px;
    mask-image: linear-gradient(#0006, #0008 40%, transparent 89%);
  }
  .place {
    grid-row: 1 / span 3;
    display: grid;
    grid-template-rows: subgrid;
    min-width: 0;
    align-self: stretch;
    text-align: center;
  }
  .figure {
    display: grid;
    place-items: center;
    min-height: 0;
    height: var(--figure-height);
    container-type: inline-size;
  }
  .laptop,
  .cloud,
  .phone {
    font-size: min(16px, 6.7cqw, calc(var(--figure-height) / 12));
    position: relative;
  }
  .screen {
    width: 100%;
    height: 100%;
    display: grid;
    place-items: center;
    background: linear-gradient(135deg, #f9fbff, #e8eef6);
    overflow: hidden;
  }
  .laptop {
    display: grid;
    justify-items: center;
    width: 14.5em;
    filter: drop-shadow(0.12em 0.26em 0 #263a4e1c);
  }
  .lid {
    width: 88%;
    aspect-ratio: 1.58;
    padding: 0.4em 0.29em 0.38em;
    position: relative;
    background: #273443;
    border: 1px solid #1c2733;
    box-shadow: inset 0 1px 0 #84909d;
  }
  .lid::before {
    content: "";
    position: absolute;
    left: 49%;
    top: 0.09em;
    width: 0.19em;
    height: 0.19em;
    background: #9ea9b7;
  }
  .base {
    width: 100%;
    height: 0.52em;
    background: linear-gradient(
      #9ca9b7 12%,
      #707f90 13%,
      #586879 70%,
      #364455 71%
    );
    clip-path: polygon(5% 0, 95% 0, 100% 50%, 98% 100%, 2% 100%, 0 50%);
  }
  .base::after {
    content: "";
    display: block;
    width: 18%;
    height: 30%;
    background: #455568;
    margin: 0 auto;
  }
  .phone {
    display: grid;
    place-items: center;
    width: 4.8em;
    height: 9em;
    padding: 0.28em;
    border: 0.1em solid #253241;
    border-radius: 0.38em;
    background: #314050;
    box-shadow: 0.12em 0.18em 0 #899aaa;
  }
  .phone .screen {
    border-radius: 0.12em;
  }
  .phone::before,
  .phone::after {
    content: "";
    position: absolute;
    left: 36%;
    width: 28%;
    height: 0.18em;
    background: #415163;
  }
  .phone::before {
    top: 0.46em;
  }
  .phone::after {
    bottom: 0.5em;
  }
  .cloud {
    width: 14em;
    height: 12em;
    display: grid;
    place-items: center;
  }
  .cloud-drawing {
    width: 100%;
    height: 100%;
    stroke: #566c84;
    stroke-width: 2;
    stroke-linejoin: round;
    fill: #edf3fb;
    filter: drop-shadow(0.14em 0.23em 0 #bdcbdc);
  }
  .owner {
    position: absolute;
    right: 8%;
    bottom: 19%;
    width: 1.85em;
    aspect-ratio: 1;
    display: grid;
    place-items: center;
    background: #fbfcfd;
    border: 1px solid #798b9e;
    box-shadow: 2px 2px 0 #c3d0de;
  }
  .owner :global(svg) {
    width: 62%;
    height: 62%;
    color: #35485e;
  }
  .vault {
    --face: #e0ebff;
    --edge: #6487c8;
    --key: #315eac;
    position: relative;
    display: grid;
    place-items: center;
    width: 3.1em;
    height: 3.7em;
    isolation: isolate;
  }
  .vault::before {
    content: "";
    position: absolute;
    inset: 0;
    transform: translate(-0.23em, 0.24em);
    background: #c3d6f6;
    border: 1px solid var(--edge);
  }
  .vault-face {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-direction: column;
    gap: 0.23em;
    border: 1px solid var(--edge);
    color: var(--key);
    background: var(--face);
  }
  .vault-face::before {
    content: "";
    position: absolute;
    top: -1px;
    right: -1px;
    width: 0.75em;
    aspect-ratio: 1;
    background: linear-gradient(45deg, var(--edge) 49%, #f1f5fb 50%);
  }
  .vault-face :global(svg) {
    width: 1.45em;
    height: 1.45em;
  }
  .vault-face i {
    width: 1.35em;
    height: 1px;
    background: currentColor;
    opacity: 0.6;
  }
  .cloud .vault {
    position: absolute;
    top: 44%;
    left: 50%;
    transform: translate(-50%, -25%);
  }
  .place:not(.stored) .vault-face {
    border-style: dashed;
  }
  .stored .vault {
    --face: var(--accent);
    --edge: #193f9f;
    --key: #fff;
  }
  .stored .vault::before {
    background: #9cb8f0;
  }
  h3 {
    margin: 17px 0 0;
    align-self: start;
    font: 580 clamp(1rem, 1.8vw, 1.38rem)/1.22 var(--display);
    letter-spacing: -0.045em;
    text-wrap: balance;
  }
  .copy-status {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    margin-top: 6px;
    color: #546171;
    font: 400 0.8rem/1.4 var(--mono);
  }
  .stored .copy-status {
    color: #204fb6;
  }
  .copy-mark {
    width: 8px;
    height: 9px;
    background: #4673cf;
    box-shadow: -2px 2px 0 #bed0ee;
  }
  .connection {
    position: relative;
    grid-row: 1;
    height: 1.5px;
    margin: calc(var(--figure-height) / 2) 0 0;
    background: #8ba0b7;
    color: #637991;
  }
  .connection::before,
  .connection::after {
    content: "";
    position: absolute;
    top: 50%;
    width: 6px;
    height: 6px;
    border-right: 1.5px solid;
    border-top: 1.5px solid;
  }
  .connection.connected {
    background: var(--accent);
    color: var(--accent);
  }
  .connection::before {
    left: 0;
    transform: translateY(-50%) rotate(-135deg);
  }
  .connection::after {
    right: 0;
    transform: translateY(-50%) rotate(45deg);
  }
  .connection i {
    position: absolute;
    top: 50%;
    width: 8px;
    height: 10px;
    border: 1px solid #1543ae;
    background: #5688f2;
    box-shadow: -2px 2px 0 #c1d4fa;
    animation: send 0.65s linear both;
  }
  .connection i.back {
    animation-direction: reverse;
  }
  .connection i::after {
    content: "";
    position: absolute;
    top: -1px;
    right: -1px;
    width: 3px;
    height: 3px;
    background: linear-gradient(45deg, #1543ae 49%, #fbfcfd 50%);
  }
  @keyframes send {
    from {
      left: 0;
      transform: translate(-50%, -50%);
    }
    to {
      left: 100%;
      transform: translate(-50%, -50%);
    }
  }
  .map-action {
    grid-row: 4;
    grid-column: var(--action-column);
    justify-self: center;
    margin-top: 21px;
  }
  @media (max-width: 650px) {
    .map {
      --figure-height: clamp(82px, 19vw, 122px);
      grid-template-columns:
        minmax(0, 1fr) minmax(11px, 0.18fr) minmax(0, 1.08fr)
        minmax(11px, 0.18fr) minmax(0, 1fr);
      padding: 25px 10px 20px;
    }
    h3 {
      font-size: clamp(0.875rem, 3vw, 1.1rem);
      margin-top: 9px;
    }
    .copy-status {
      font-size: 0.72rem;
      margin-top: 5px;
    }
    .connection::before,
    .connection::after {
      width: 4px;
      height: 4px;
    }
    .map-action {
      grid-column: 1/-1;
      margin-top: 24px;
      justify-self: stretch;
      padding-inline: 4px;
    }
    .owner {
      min-width: 18px;
    }
    .map::before {
      background-size: 12px 12px;
    }
  }
  @media (prefers-reduced-motion: reduce) {
    .connection i {
      animation: none;
    }
  }
</style>
