<template>
  <div class="row">
    <div class="main__list-wrap">
      <div v-for="item in list" :key="item.name" class="main__list-item">
        <ListItem v-bind="{name: item.name, shader: item.shader}" />
      </div>
    </div>
  </div>
</template>

<style scope>
.placeholder {
  height: 1800px;
  background-color: yellow;
}

.row {
  margin: 0 16px;
}
#code {
  white-space: pre-wrap;
}

.main__list-wrap {
  display: flex;
  flex-wrap: wrap;
  margin: -8px;
  justify-content: center;
}
</style>

<script lang="ts">
import { Vue, Component, Prop } from 'vue-property-decorator'
import Canvas from '~/components/Canvas/Canvas.vue'
import ListItem from '~/components/ListItem/ListItem.vue'

const asyncData = async ({ params }: any) => {
  const metaData = require('../shaders/meta.json')
  const jsonData = require('../shaders/20200303.json')

  const list = metaData.list.map((name: string) => ({
    name,
    link: `/detail/${name}`,
    shader: require(`../shaders/${name}.json`).body
  }))

  return { source: jsonData.body, title: 'haga', list }
}

export default Vue.extend({
  asyncData,
  components: { Canvas, ListItem }
})
</script>
