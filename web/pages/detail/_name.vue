<template>
  <div class="row">
    <Canvas v-bind:shader="source" v-bind:name="name" />
  </div>
</template>

<style>
#code {
  white-space: pre-wrap;
}
.row {
  margin: 0 16px;
}
</style>

<script lang="ts">
import Canvas from '~/components/Canvas.vue'
import { Vue, Component, Prop } from 'vue-property-decorator'

const asyncData = async ({ params }: any) => {
  const metaData = require('../../shaders/meta.json')
  const jsonData = require(`../../shaders/${params.name}.json`)
  // console.log(jsonData.body)
  return { source: jsonData.body, title: 'haga', name: params.name }
}

// @Component({ components: { Canvas } })
// export default class Index extends Vue {
//   asyncData() {
//     const jsonData = require('../shaders/20200218.json')
//     console.log(jsonData.body)
//     // this.source = jsonData.body
//     return { source: jsonData.body, title: 'haga' }
//   }
// }

export default {
  asyncData,
  components: { Canvas }
}
</script>
