<template>
  <div>
    <h1>title</h1>
    <Canvas v-bind:shader="source" />
  </div>
</template>

<style>
#code {
  white-space: pre-wrap;
}
</style>

<script lang="ts">
import Canvas from '~/components/Canvas.vue'
import { Vue, Component, Prop } from 'vue-property-decorator'

const asyncData = async ({ params }: any) => {
  const jsonData = require('../test.json')
  // console.log(jsonData.body)
  return { source: jsonData.body, title: 'haga' }
}

// @Component({ components: { Canvas } })
// export default class Index extends Vue {
//   private source!: string

//   asyncData() {
//     const jsonData = require('../test.json')
//     console.log(jsonData.body)
//     this.source = jsonData.body
//     return { source: jsonData.body, title: 'haga' }
//   }
// }

export default {
  asyncData,
  components: { Canvas }
}
</script>
