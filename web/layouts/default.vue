<template>
  <div>
    <nav
      class="navbar header has-shadow"
      role="navigation"
      aria-label="main navigation"
    >
      <div class="logo">
        <p>
          <nuxt-link to="/">aodnawg</nuxt-link>
        </p>
      </div>
    </nav>

    <section class="main-content columns">
      <div class="container column is-10">
        <nuxt />
      </div>
    </section>
  </div>
</template>

<style scoped>
.logo {
  display: flex;
  justify-content: space-around;
  align-items: center;
  font-size: 1.4rem;
  margin-top: 4px;
}
.logo a {
  color: #434343;
}
</style>

<script>
export default {
  data() {
    return {
      items: [
        {
          title: 'Home',
          icon: 'home',
          to: { name: 'index' }
        },
        {
          title: 'Inspire',
          icon: 'lightbulb',
          to: { name: 'inspire' }
        }
      ]
    }
  }
}
</script>
