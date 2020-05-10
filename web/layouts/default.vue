<template>
  <div class="frame">
    <div class="logo-wrap">
      <nuxt-link to="/" class="link">
        <h1 class="logo">
          aodnawg
        </h1>
        <h2 class="headline">glsl works.</h2>
      </nuxt-link>
    </div>
    <section>
      <nuxt />
    </section>
  </div>
</template>

<style scoped lang="scss">
.frame {
  display: grid;
  margin: 32px auto;
  width: 1168px;
  grid-template-columns: 1fr 3fr;
  gap: 32px;

  @media (max-width: 1200px) {
    width: 100%;
    display: grid;
    margin: 32px;
    grid-template-columns: 1fr 3fr;
    gap: 32px;
  }

  @media (max-width: 768px) {
    display: flex;
    flex-direction: column;
    margin: 0 16px;
  }
}

.logo-wrap {
  color: #111111;
  a {
    color: #111111;
  }
  @media (max-width: 768px) {
    display: flex;
    align-items: baseline;
    margin-bottom: 32px;
  }
}

.logo {
  font-size: 2.4rem;
  font-family: 'Roboto', sans-serif;
  font-weight: 900;

  @media (max-width: 768px) {
    margin-right: 16px;
  }
}

.headline {
  font-size: 2rem;
  font-family: 'Roboto', sans-serif;
  font-weight: 200;
}
</style>

<script></script>
