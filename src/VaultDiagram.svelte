<script>
  import { Check } from "lucide-svelte";

  let { created, linked } = $props();
</script>

{#snippet node(artwork, title, detail, ready = false)}
  <div class="node">
    <div class="object" aria-hidden="true">
      <img
        class={"drawing " + artwork}
        src={"/diagram/" + artwork + ".webp"}
        alt=""
      />
    </div>
    <div class="caption">
      <strong>{title}</strong>
      <span>
        {#if ready}<Check size={14} />{/if}{detail}
      </span>
    </div>
  </div>
{/snippet}

<div
  class="diagram"
  class:linked
  role="img"
  aria-label="This device and your other device each keep a local vault. An arrow from each device points to Dropbox cloud storage, which syncs the encrypted copy."
>
  {@render node("laptop", "This device", "Local vault", created)}
  <div class="connector" aria-hidden="true"><i></i></div>
  {@render node("storage", "Cloud storage", "Dropbox")}
  <div class="connector reverse" aria-hidden="true"><i></i></div>
  {@render node("phone", "Other device", "Local vault", linked)}
</div>

<style>
  .diagram {
    --drawing-height: clamp(145px, 15vw, 192px);
    --signal: #9ce1ff;
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(16px, 0.47fr) minmax(
        0,
        0.92fr
      ) minmax(16px, 0.47fr) minmax(0, 1fr);
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
  .storage {
    width: 84%;
    height: 84%;
  }
  .phone {
    height: 91%;
  }
  .caption {
    text-align: center;
    margin-top: 17px;
  }
  .caption strong {
    display: block;
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
    font: 400 0.825rem/1.5 var(--mono);
  }
  .caption :global(svg) {
    color: var(--signal);
  }
  .connector {
    position: relative;
    height: 2px;
    margin: calc(var(--drawing-height) / 2) 1px 0;
    color: var(--signal);
    background: linear-gradient(90deg, #77bbdfaa, var(--signal));
  }
  .connector::before,
  .connector::after {
    content: "";
    position: absolute;
    top: 50%;
  }
  .connector::before {
    width: 5px;
    height: 5px;
    left: 0;
    transform: translateY(-50%);
    border: 1px solid var(--signal);
    background: #15345c;
  }
  .connector::after {
    right: 0;
    width: 8px;
    height: 8px;
    border-top: 2px solid;
    border-right: 2px solid;
    transform: translateY(-50%) rotate(45deg);
  }
  .reverse {
    transform: rotate(180deg);
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
      animation: sync 0.95s ease-in-out 2;
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
      grid-template-columns: minmax(0, 1fr) minmax(12px, 0.2fr) minmax(
          0,
          1.04fr
        ) minmax(12px, 0.2fr) minmax(0, 1fr);
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
    .caption {
      margin-top: 12px;
    }
    .caption strong {
      font-size: clamp(0.87rem, 2.95vw, 1.05rem);
    }
    .caption span {
      font-size: 0.75rem;
      margin-top: 3px;
    }
    .connector {
      margin-inline: 0;
    }
    .connector::after {
      width: 5px;
      height: 5px;
    }
    .connector::before {
      width: 2px;
      height: 2px;
    }
  }
</style>
