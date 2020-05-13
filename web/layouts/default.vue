<template>
  <div class="frame">
    <header id="header">
      <div class="sticky">
        <nuxt-link to="/" class="link">
          <div class="logo-wrap">
            <h1 class="logo">aodnawg</h1>
            <h2 class="headline">glsl works.</h2>
          </div>
        </nuxt-link>
        <div class="social">
          <a href="https://www.instagram.com/aodnawg/" target="_blank">
            <fa :icon="faInstagram" />
          </a>
          <a href="https://twitter.com/aodnawg" target="_blank">
            <fa :icon="faTwitter" />
          </a>
        </div>
      </div>
    </header>

    <section class="main">
      <nuxt />
    </section>
  </div>
</template>

<style scoped lang="scss">
#header {
  color: #111111;
  a {
    color: #111111;
  }

  @media (max-width: 768px) {
    position: fixed;
    top: 0;
    left: 0;
    z-index: 1;
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: rgba(255, 255, 255, 0.95);
    padding: 8px 16px;
  }
}

.main {
  @media (max-width: 768px) {
    margin: 64px 16px 0;
  }
}

.frame {
  display: grid;
  width: 1168px;
  grid-template-columns: 1fr 3fr;
  gap: 32px;
  margin: 48px auto;

  @media (max-width: 1200px) {
    width: auto;
    display: grid;
    margin: 48px 32px;
  }

  @media (max-width: 768px) {
    display: flex;
    flex-direction: column;
    /* margin: 0 16px; */
    margin: 0;
  }
}

.sticky {
  position: sticky;
  top: 48px;

  @media (max-width: 768px) {
    position: static;
  }
}

.logo-wrap {
  margin-bottom: 24px;

  @media (max-width: 768px) {
    margin-bottom: 0;

    display: flex;
    align-items: baseline;
  }
}

.logo {
  font-size: 3rem;
  font-family: 'Roboto', sans-serif;
  font-weight: 900;

  @media (max-width: 768px) {
    font-size: 2rem;
    margin-right: 8px;
  }
}

.headline {
  font-size: 2.2rem;
  font-family: 'Roboto', sans-serif;
  font-weight: 200;
  @media (max-width: 768px) {
    font-size: 1.4rem;
  }
}

.social {
  font-size: 2rem;
  color: #111111;
  display: flex;
  margin: -6px;
  > * {
    margin: 6px;
  }
}
</style>

<script>
import { faInstagram, faTwitter } from '@fortawesome/free-brands-svg-icons'
export default {
  computed: {
    faInstagram() {
      return faInstagram
    },
    faTwitter() {
      return faTwitter
    }
  }
}
</script>
