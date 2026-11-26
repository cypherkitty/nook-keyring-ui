<script>
  import { Check, Cloud, LockKeyhole } from "lucide-svelte";

  let { created, linked } = $props();
</script>

{#snippet vaultScreen()}
  <div class="screen"><img src="/vault-module.jpg" alt="" /></div>
{/snippet}

<div
  class="diagram"
  class:linked
  role="img"
  aria-label="This device and your other device each keep a local vault. An arrow from each device points to Dropbox cloud storage, which syncs the encrypted copy."
>
  <div class="node">
    <div class="object" aria-hidden="true">
      <div class="laptop">
        <div class="lid">{@render vaultScreen()}</div>
        <div class="base"></div>
      </div>
    </div>
    <div class="caption">
      <strong>This device</strong><span>
        {#if created}<Check size={14} />{/if}Local vault
      </span>
    </div>
  </div>

  <div class="connector" aria-hidden="true"><i></i></div>

  <div class="node">
    <div class="object" aria-hidden="true">
      <div class="storage">
        <Cloud class="cloud" strokeWidth={0.37} fill="url(#cloud-face)">
          <defs>
            <linearGradient id="cloud-face" x1="0" x2=".8" y1="0" y2="1">
              <stop stop-color="#849276" />
              <stop offset=".43" stop-color="#48573f" />
              <stop offset="1" stop-color="#26311f" />
            </linearGradient>
          </defs>
        </Cloud>
        <LockKeyhole class="cloud-lock" strokeWidth={1.6} />
      </div>
    </div>
    <div class="caption">
      <strong>Cloud storage</strong><span>Dropbox</span>
    </div>
  </div>

  <div class="connector reverse" aria-hidden="true"><i></i></div>

  <div class="node">
    <div class="object" aria-hidden="true">
      <div class="phone">{@render vaultScreen()}</div>
    </div>
    <div class="caption">
      <strong>Other device</strong><span>
        {#if linked}<Check size={14} />{/if}Local vault
      </span>
    </div>
  </div>
</div>

<style>
  .diagram {
    --object-height: clamp(125px, 14vw, 178px);
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(18px, 0.46fr) minmax(
        0,
        0.88fr
      ) minmax(18px, 0.46fr) minmax(0, 1fr);
    align-items: start;
    position: relative;
    isolation: isolate;
    overflow: hidden;
    padding: clamp(30px, 4.2vw, 56px) clamp(22px, 5vw, 72px)
      clamp(27px, 3vw, 42px);
    background:
      radial-gradient(ellipse at 50% 20%, #2a342365, transparent 76%), #191e16;
  }
  .diagram::before {
    content: "";
    position: absolute;
    z-index: -1;
    inset: 0;
    background-image: radial-gradient(#bdcfa72e 0.8px, transparent 0.9px);
    background-size: 18px 18px;
    mask-image: linear-gradient(#0007, #000b 56%, transparent 98%);
  }
  .node,
  .caption {
    min-width: 0;
  }
  .object {
    height: var(--object-height);
    display: grid;
    place-items: center;
    position: relative;
  }
  .object::before {
    content: "";
    position: absolute;
    left: 12%;
    right: 12%;
    bottom: 2%;
    height: 9%;
    border-radius: 50%;
    background: #080c05a6;
    filter: blur(7px);
    z-index: -1;
  }
  .caption {
    margin-top: 11px;
    text-align: center;
  }
  .caption strong {
    display: block;
    font: 550 clamp(0.97rem, 1.8vw, 1.32rem)/1.25 var(--display);
    letter-spacing: -0.035em;
  }
  .caption span {
    display: flex;
    gap: 4px;
    justify-content: center;
    align-items: center;
    margin-top: 5px;
    color: #b5bfac;
    font-size: 0.875rem;
  }
  .caption :global(svg) {
    color: var(--lime);
  }
  .laptop {
    width: min(100%, 225px);
    display: flex;
    align-items: center;
    flex-direction: column;
    filter: drop-shadow(0 5px 5px #06090455);
  }
  .lid {
    position: relative;
    width: 89%;
    aspect-ratio: 1.57;
    padding: 3.2% 2.1% 2.6%;
    border-radius: 7% 7% 3% 3% / 10% 10% 5% 5%;
    border: 1px solid #929c87;
    background: linear-gradient(
      130deg,
      #505748,
      #171c14 19%,
      #11150e 75%,
      #555d4d
    );
    box-shadow: inset 0 0 0 1px #191e15;
  }
  .lid::before,
  .phone::before {
    content: "";
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    z-index: 1;
  }
  .lid::before {
    top: 2%;
    width: 1.7%;
    aspect-ratio: 1;
    border-radius: 50%;
    background: #394431;
    box-shadow: inset 0 0 0 1px #141910;
  }
  .screen {
    width: 100%;
    height: 100%;
    position: relative;
    overflow: hidden;
    background: #151a11;
    border-radius: 3px;
    box-shadow: 0 0 0 1px #080c05;
    display: grid;
    place-items: center;
  }
  .screen img {
    display: block;
    width: 100%;
    height: 100%;
    object-fit: cover;
  }
  .base {
    position: relative;
    margin-top: -1px;
    width: 100%;
    height: clamp(4px, 0.65vw, 9px);
    border-top: 1px solid #c1cbb7;
    border-radius: 12% 12% 38% 38% / 22% 22% 85% 85%;
    background: linear-gradient(#8e9983, #565e4e 49%, #353c2e 55%, #767f6c 95%);
  }
  .base::before {
    content: "";
    position: absolute;
    left: 40%;
    width: 20%;
    height: 36%;
    top: 0;
    background: #424a3a;
    border-radius: 0 0 5px 5px;
  }
  .phone {
    position: relative;
    width: min(37%, 76px);
    aspect-ratio: 0.49;
    padding: 3px;
    border: 1px solid #bbc4b1;
    border-radius: 22% / 11%;
    background: linear-gradient(
      140deg,
      #919a86,
      #242b1d 15%,
      #11160e 65%,
      #65705a
    );
    box-shadow:
      inset 0 0 0 1.5px #272e21,
      2px 2px 0 #404936,
      0 7px 9px #0a0e0755;
  }
  .phone .screen {
    border-radius: 19% / 9.5%;
    background: #161b12;
  }
  .phone .screen img {
    position: absolute;
    width: 136%;
    height: auto;
    max-width: none;
    mask-image: linear-gradient(transparent, #000 14%, #000 87%, transparent);
  }
  .phone::before {
    width: 32%;
    height: 3.2%;
    top: 4.6%;
    border-radius: 6px;
    background: #090d07;
  }
  .phone::after {
    content: "";
    position: absolute;
    left: 32%;
    right: 32%;
    bottom: 5%;
    height: 1.4%;
    border-radius: 3px;
    background: #8d9882;
  }
  .storage {
    width: min(84%, 150px);
    aspect-ratio: 1;
    position: relative;
    display: grid;
    place-items: center;
  }
  .storage :global(.cloud) {
    width: 100%;
    height: 100%;
    color: #c5d3b7;
    filter: drop-shadow(0 1px 0 #74826a) drop-shadow(0 2px 0 #48553c)
      drop-shadow(0 3px 0 #394930) drop-shadow(0 4px 0 #2a3623)
      drop-shadow(0 7px 8px #090e074d);
  }
  .storage :global(.cloud-lock) {
    position: absolute;
    width: 23%;
    height: 23%;
    top: 43%;
    left: 38%;
    color: #d4e6c3;
    filter: drop-shadow(0 1px 1px #121a0e);
  }
  .connector {
    align-self: start;
    position: relative;
    color: #c3dea5;
    height: 2px;
    margin: calc(var(--object-height) / 2) 4px 0;
    background: linear-gradient(90deg, #677a56, #bdd69f);
  }
  .connector::before,
  .connector::after {
    content: "";
    position: absolute;
  }
  .connector::before {
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 5px;
    height: 5px;
    border-radius: 50%;
    background: #849a71;
  }
  .connector::after {
    right: 0;
    top: 50%;
    width: 9px;
    height: 9px;
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
      border-radius: 50%;
      background: var(--lime);
      opacity: 0;
      box-shadow: 0 0 7px #c9f09b;
      animation: sync 0.95s ease-in-out 2;
    }
    @keyframes sync {
      10% {
        opacity: 1;
      }
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
      --object-height: clamp(80px, 19vw, 116px);
      grid-template-columns: minmax(0, 1fr) minmax(12px, 0.22fr) minmax(
          0,
          1fr
        ) minmax(12px, 0.22fr) minmax(0, 1fr);
      padding: 29px 10px 25px;
    }
    .caption strong {
      font-size: clamp(0.84rem, 2.9vw, 1rem);
    }
    .caption span {
      font-size: 0.76rem;
      margin-top: 4px;
    }
    .caption {
      margin-top: 7px;
    }
    .connector {
      margin-inline: 0;
    }
    .connector::after {
      width: 6px;
      height: 6px;
    }
    .connector::before {
      width: 3px;
      height: 3px;
    }
    .storage {
      width: 86%;
    }
    .phone {
      padding: 1.5px;
    }
  }
</style>
