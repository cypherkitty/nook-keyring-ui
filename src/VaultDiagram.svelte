<script>
  import { Check, LockKeyhole, UserRound } from "lucide-svelte";

  let { created, linked } = $props();
</script>

{#snippet node(artwork, title, ready = false)}
  <div class="node">
    <div class="object" aria-hidden="true">
      {#if artwork === "storage"}
        <div class="cloud-account">
          <img class="drawing" src="/diagram/storage.webp" alt="" />
          <LockKeyhole class="cloud-lock" strokeWidth={1.7} />
          <span class="account-owner"><UserRound strokeWidth={1.8} /></span>
        </div>
      {:else}
        <img
          class={"drawing " + artwork}
          src={"/diagram/" + artwork + ".webp"}
          alt=""
        />
      {/if}
    </div>
    <div class="caption">
      <strong>{title}</strong>
      <span>
        {#if ready}<Check size={14} />{/if}Encrypted vault
      </span>
    </div>
  </div>
{/snippet}

<div
  class="diagram"
  class:linked
  role="img"
  aria-label="This device, your own cloud account, and your other device each store an encrypted copy of your vault. Password changes sync in both directions through your cloud account."
>
  {@render node("laptop", "This device", created)}
  <div class="connector" aria-hidden="true"><i></i></div>
  {@render node("storage", "Your cloud account")}
  <div class="connector next-leg" aria-hidden="true"><i></i></div>
  {@render node("phone", "Other device", linked)}
</div>

<style>
  .diagram {
    --drawing-height: clamp(145px, 15vw, 192px);
    --signal: #9ce1ff;
    display: grid;
    grid-template-columns:
      minmax(0, 1fr) minmax(16px, 0.47fr) minmax(0, 0.92fr)
      minmax(16px, 0.47fr) minmax(0, 1fr);
    grid-template-rows: var(--drawing-height) auto auto;
    grid-auto-flow: column;
    position: relative;
    isolation: isolate;
    align-items: start;
    padding: clamp(31px, 3.6vw, 48px) clamp(23px, 5.4vw, 76px)
      clamp(30px, 3.2vw, 44px);
    color: #f7faff;
    background: radial-gradient(
      ellipse at 55% 12%,
      #234777,
      #152f58 60%,
      #102747
    );
  }
  .diagram::before,
  .diagram::after {
    content: "";
    position: absolute;
    pointer-events: none;
  }
  .diagram::before {
    z-index: -1;
    inset: 0;
    background-image:
      linear-gradient(#a1ceff12 1px, transparent 1px),
      linear-gradient(90deg, #a1ceff12 1px, transparent 1px),
      linear-gradient(#afdcff13 1px, transparent 1px),
      linear-gradient(90deg, #afdcff13 1px, transparent 1px);
    background-size:
      20px 20px,
      20px 20px,
      100px 100px,
      100px 100px;
    mask-image: linear-gradient(black 48%, #0006);
  }
  .diagram::after {
    --mark: linear-gradient(#a7cefaad 0 0);
    inset: 14px;
    background:
      var(--mark) left top / 10px 1px,
      var(--mark) left top / 1px 10px,
      var(--mark) right top / 10px 1px,
      var(--mark) right top / 1px 10px,
      var(--mark) left bottom / 10px 1px,
      var(--mark) left bottom / 1px 10px,
      var(--mark) right bottom / 10px 1px,
      var(--mark) right bottom / 1px 10px;
    background-repeat: no-repeat;
  }
  .node {
    min-width: 0;
    display: grid;
    grid-row: 1 / span 3;
    grid-template-rows: subgrid;
    align-self: stretch;
  }
  .object {
    height: var(--drawing-height);
    display: grid;
    place-items: center;
  }
  .drawing {
    display: block;
    width: 100%;
    height: 100%;
    min-width: 0;
    min-height: 0;
    object-fit: contain;
    filter: drop-shadow(0 7px 5px #0714294d);
  }
  .cloud-account {
    position: relative;
    width: min(86%, calc(var(--drawing-height) * 0.9));
    aspect-ratio: 420 / 396;
  }
  .cloud-account :global(.cloud-lock) {
    position: absolute;
    width: 27%;
    height: 29%;
    top: 42%;
    left: 55%;
    color: #98eaff;
    transform: translate(-50%, -50%) skewY(-11deg);
    filter: drop-shadow(0 0 1px #37caff) drop-shadow(0 0 3px #22bdff);
  }
  .account-owner {
    position: absolute;
    right: -3%;
    bottom: 2%;
    display: grid;
    place-items: center;
    width: clamp(18px, 2.15vw, 31px);
    aspect-ratio: 1;
    border: 1px solid #a7dafb;
    border-radius: 50%;
    background: #dbf0ff;
    color: #173d69;
    box-shadow: 0 0 0 2px #1a385d;
  }
  .account-owner :global(svg) {
    width: 63%;
    height: 63%;
  }
  .phone {
    height: 91%;
  }
  .caption {
    display: contents;
  }
  .caption strong {
    align-self: end;
    text-align: center;
    text-wrap: balance;
    margin-top: 17px;
    font: 550 clamp(1.05rem, 1.65vw, 1.35rem)/1.26 var(--display);
    letter-spacing: -0.035em;
  }
  .caption span {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 5px;
    margin-top: 5px;
    color: #c0d9f4;
    text-align: center;
    font: 400 0.825rem/1.5 var(--mono);
  }
  .caption :global(svg) {
    color: var(--signal);
  }
  .connector {
    grid-row: 1;
    position: relative;
    height: 2px;
    margin: calc(var(--drawing-height) / 2) 2px 0;
    color: var(--signal);
    background: var(--signal);
  }
  .connector::before,
  .connector::after {
    content: "";
    position: absolute;
    top: 50%;
    width: 7px;
    height: 7px;
    border-top: 2px solid;
    border-right: 2px solid;
  }
  .connector::before {
    left: 0;
    transform: translateY(-50%) rotate(-135deg);
  }
  .connector::after {
    right: 0;
    transform: translateY(-50%) rotate(45deg);
  }
  @media (prefers-reduced-motion: no-preference) {
    .linked .connector i {
      position: absolute;
      top: -2px;
      left: 0;
      width: 6px;
      height: 6px;
      opacity: 0;
      background: #e2f8ff;
      box-shadow: 0 0 8px #8ad9ff;
      animation: sync 0.8s ease-in-out;
    }
    .linked .next-leg i {
      animation-delay: 0.8s;
    }
    @keyframes sync {
      10%,
      90% {
        opacity: 1;
      }
      to {
        left: 100%;
        opacity: 0;
      }
    }
  }
  @media (max-width: 650px) {
    .diagram {
      --drawing-height: clamp(84px, 20vw, 125px);
      grid-template-columns:
        minmax(0, 1fr) minmax(12px, 0.2fr) minmax(0, 1.04fr)
        minmax(12px, 0.2fr) minmax(0, 1fr);
      padding: 30px 11px 27px;
    }
    .diagram::before {
      background-size:
        14px 14px,
        14px 14px,
        70px 70px,
        70px 70px;
    }
    .diagram::after {
      inset: 7px;
    }
    .caption strong {
      margin-top: 12px;
      font-size: clamp(0.87rem, 2.95vw, 1.05rem);
    }
    .caption span {
      font-size: 0.75rem;
      margin-top: 3px;
    }
    .connector {
      margin-inline: 0;
    }
    .connector::before,
    .connector::after {
      width: 4px;
      height: 4px;
    }
  }
</style>
