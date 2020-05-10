<template>
  <div>
    <div class="main__list-wrap">
      <div v-for="item in list" :key="item.name" class="main__list-item">
        <ListItem v-bind="{ name: item.name, shader: item.shader }" />
      </div>
    </div>
  </div>
</template>

<style scope lang="scss">
#code {
  white-space: pre-wrap;
}

.main__list-wrap {
  display: grid;
  gap: 18px;
  grid-template-columns: 1fr 1fr 1fr 1fr;
  grid-auto-rows: auto;

  @media (max-width: 1200px) {
    grid-template-columns: 1fr 1fr 1fr;
  }

  @media (max-width: 768px) {
    grid-template-columns: 1fr 1fr;
  }
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import Canvas from '~/components/Canvas/Canvas.vue'
import ListItem from '~/components/ListItem/ListItem.vue'

const asyncData = async ({ params }: any) => {
  const metaData = require('../shaders/list.json')
  const jsonData = require('../shaders/20200303.json')

  const list = metaData.list.map((name: string) => ({
    name,
    link: `/detail/${name}`,
    shader: require(`../shaders/${name}.json`).body
  }))

  return { source: jsonData.body, title: 'haga', list }
}

export default Vue.extend({
  components: { Canvas, ListItem },
  asyncData
})
</script>
